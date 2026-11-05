import 'package:decimal/decimal.dart';

import '../../domain/entities/order_list_order.dart';
import '../../domain/enums/order_type.dart';
import '../../domain/repositories/order_repository.dart';

/// API v2 订单详情响应适配器。
///
/// 详情接口是历史接口，字段存在字符串、数字和 null 混用的情况；
/// 这里统一做容错转换，页面只依赖 domain 对象。
class OrderDetailResponse {
  final Map<String, dynamic> json;

  const OrderDetailResponse(this.json);

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) => OrderDetailResponse(json);

  OrderDetail toDomain() {
    final stateCode = _int(json['orderstate']);
    final typeCode = _int(json['ordertype']);
    final isCredit =
        _bool(json['iscreditorder']) ??
        typeCode == BackendOrderType.credit.code || typeCode == BackendOrderType.fuluIntegral.code || typeCode == BackendOrderType.baiLiHuiIntegral.code;
    final addressJson = _map(json['addressinfo']);

    int pointsValue = 0;
    if (isCredit) {
      for (final key in const ['payintegralcount', 'integralcount', 'creditamount', 'credit', 'integralamount', 'orderamount']) {
        final val = _int(json[key]) ?? (Decimal.tryParse(json[key]?.toString() ?? '')?.round().toBigInt().toInt());
        if (val != null && val > 0) {
          pointsValue = val;
          break;
        }
      }
    }

    final products = (_list(json['products'])).map((p) => _product(p, isCredit)).toList(growable: false);

    if (isCredit && pointsValue == 0) {
      for (final p in products) {
        if (p.totalCents > 0) {
          pointsValue += p.totalCents * (p.quantity > 0 ? p.quantity : 1);
        }
      }
    }

    final productTotal = isCredit ? (pointsValue > 0 ? pointsValue : 0) : (_cents(json['orderamount']) ?? 0);
    final payAmount = isCredit ? (pointsValue > 0 ? pointsValue : 0) : (_cents(json['payamount']) ?? 0);
    final pointsCostValue = pointsValue > 0 ? pointsValue : (_int(json['payintegralcount']) ?? _int(json['integralcount']) ?? _int(json['creditamount']));

    final shipInfo = _map(json['shipinfo']);
    final traces = _list(shipInfo['traces']);
    final timeline = traces.map(_timeline).whereType<OrderTimeline>().toList(growable: false);
    final orderType = _legacyOrderType(typeCode, isCredit);

    return OrderDetail(
      id: _text(json['orderid']) ?? '',
      orderNo: _text(json['ordersn']) ?? '',
      status: _legacyStatus(stateCode),
      backendStateCode: stateCode,
      statusText: _text(json['orderstatedesc']) ?? '',
      backendTypeCode: typeCode,
      orderTypeLabel: BackendOrderType.fromCode(typeCode)?.label,
      isCreditOrder: isCredit,
      items: products,
      address: OrderAddress(
        id: _text(addressJson['regionid']) ?? '',
        name: _text(addressJson['consignee']) ?? '',
        phone: _text(addressJson['mobile']) ?? '',
        province: _text(addressJson['provincename']) ?? '',
        city: _text(addressJson['cityname']) ?? '',
        district: _text(addressJson['countyname']) ?? '',
        detail: _text(addressJson['address']) ?? '',
        fullAddress: _fullAddress(addressJson) ?? '',
      ),
      mobile: _text(json['mobile']) ?? _text(addressJson['mobile']),
      productTotalCents: productTotal,
      orderAmountDescription: _text(json['orderamountdescr']),
      shippingFeeCents: _cents(json['postage']) ?? 0,
      discountCents: _sumCents(json, const ['couponamount', 'vipcouponamount', 'fullcutamont']) ?? 0,
      pointsDeductedCents: _cents(json['integralamount']) ?? 0,
      payAmountCents: payAmount,
      couponName: null,
      createTime: _date(json['createtime']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      payTime: _date(json['paytime']),
      shipTime: _date(json['delivertime']),
      receiveTime: _date(json['receivetime']),
      logisticsCompany: _text(json['shipcompanyname']),
      logisticsNo: _text(json['shipsn']) ?? _text(shipInfo['mailno']),
      remark: _text(json['remark']),
      timeline: timeline,
      orderType: orderType,
      pointsCost: pointsCostValue,
      payIntegralCount: pointsCostValue,
      exchangeTime: isCredit ? _date(json['createtime']) : null,
      pickupCode: null,
      payAmountDescription: _text(json['payamountdescr']),
      payTypeName: _text(json['paytypename']),
      paySerialNumber: _text(json['paysn']),
      userRemark: _text(json['userremark']),
      canCancel: _bool(json['cancel']) ?? false,
      canCancelAfterSale: _bool(json['cancelafter']) ?? false,
      canComment: _bool(json['cancomment']) ?? false,
      canReceive: _bool(json['canrecive']) ?? false,
      canAfterSale: _bool(json['orderafter']) ?? false,
      waitPay: _bool(json['waitpay']) ?? _bool(json['iswaitingpay']) ?? false,
      waitEndPay: _bool(json['waitendpay']) ?? false,
    );
  }

  OrderItem _product(dynamic value, bool isCredit) {
    final product = _map(value);
    int pPoints = 0;
    if (isCredit) {
      for (final key in const ['creditprice', 'creditcount', 'payintegralcount', 'integralcount', 'price']) {
        final val = _int(product[key]) ?? (Decimal.tryParse(product[key]?.toString() ?? '')?.round().toBigInt().toInt());
        if (val != null && val > 0) {
          pPoints = val;
          break;
        }
      }
    }
    final total = isCredit ? pPoints : (_cents(product['payamount']) ?? (_cents(product['price']) ?? 0));
    final price = isCredit ? pPoints : (_cents(product['price']) ?? total);
    return OrderItem(
      id: _text(product['pid']) ?? '',
      productId: _text(product['pid']) ?? '',
      skuId: _text(product['pcode']) ?? '',
      productName: _text(product['pname']) ?? '',
      skuName: _text(product['pricedesc']) ?? '',
      priceDescription: _text(product['pricedesc']),
      parameters: _parameters(product['parameter']),
      imageUrl: _text(product['img']) ?? '',
      priceCents: price,
      quantity: (_num(product['num']) ?? 1).toInt(),
      totalCents: total,
      tag: _bool(product['isgift']) == true ? '赠品' : null,
      payAmountDescription: _text(product['payamountdescr']),
      isGift: _bool(product['isgift']) ?? false,
    );
  }

  static List<OrderListParameter> _parameters(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((row) => OrderListParameter(name: _text(row['name']) ?? '', value: _text(row['value']) ?? ''))
        .where((parameter) => parameter.name.isNotEmpty && parameter.value.isNotEmpty)
        .toList(growable: false);
  }

  OrderTimeline? _timeline(dynamic value) {
    final trace = _map(value);
    final description = _text(trace['acceptstation']) ?? _text(trace['remark']);
    final time = _date(trace['accepttime']);
    if (description == null || time == null) return null;
    return OrderTimeline(time: time, title: _text(trace['action']) ?? '物流', desc: description, status: OrderStatus.shipped);
  }

  static OrderType _legacyOrderType(int? code, bool isCredit) {
    if (isCredit) return OrderType.points;
    if (code == BackendOrderType.serviceCouponSettlement.code || code == BackendOrderType.serviceCouponBuy.code) {
      return OrderType.service;
    }
    return OrderType.mall;
  }

  static OrderStatus _legacyStatus(int? code) => switch (code) {
    30 => OrderStatus.pendingPayment,
    90 => OrderStatus.pendingShipment,
    110 => OrderStatus.shipped,
    160 => OrderStatus.refunding,
    200 || 300 => OrderStatus.cancelled,
    140 || 130 || 50 || 60 || 180 || _ => OrderStatus.completed,
  };

  static String? _fullAddress(Map<String, dynamic> address) {
    final parts = [
      _text(address['provincename']),
      _text(address['cityname']),
      _text(address['countyname']),
      _text(address['address']),
    ].whereType<String>().where((value) => value.isNotEmpty).toList();
    return parts.join();
  }

  static int? _sumCents(Map<String, dynamic> json, List<String> keys) {
    var total = 0;
    var hasValue = false;
    for (final key in keys) {
      final value = _cents(json[key]);
      if (value != null) {
        total += value;
        hasValue = true;
      }
    }
    return hasValue ? total : null;
  }

  static Map<String, dynamic> _map(dynamic value) => value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  static List<dynamic> _list(dynamic value) => value is List ? value : const [];
  static String? _text(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _int(dynamic value) => int.tryParse(value?.toString() ?? '');
  static num? _num(dynamic value) => num.tryParse(value?.toString() ?? '');
  static bool? _bool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }

  static int? _cents(dynamic value) {
    final decimal = Decimal.tryParse(value?.toString() ?? '');
    return decimal == null ? null : (decimal * Decimal.fromInt(100)).round().toBigInt().toInt();
  }

  static DateTime? _date(dynamic value) {
    if (value is DateTime) return value;
    final text = _text(value);
    if (text == null) return null;
    final dotNetMatch = RegExp(r'^/Date\((-?\d+)(?:[+-]\d+)?\)/$').firstMatch(text);
    if (dotNetMatch != null) {
      final milliseconds = int.tryParse(dotNetMatch.group(1)!);
      if (milliseconds != null) return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }
    return DateTime.tryParse(text);
  }
}
