import 'package:decimal/decimal.dart';

import '../../domain/entities/order_list_order.dart';
import '../../domain/repositories/order_repository.dart';

class OrderListResponse {
  final List<OrderListOrderModel> orders;
  final int total;

  const OrderListResponse({required this.orders, required this.total});

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    final rows = json['orderlist'];
    final total = _integer(json['totalcount']);
    if (rows is! List || total == null || total < 0) {
      throw const FormatException('订单列表响应格式错误');
    }
    return OrderListResponse(orders: rows.map((row) => OrderListOrderModel.fromJson(Map<String, dynamic>.from(row as Map))).toList(), total: total);
  }

  OrderListResult toDomain({required int page, required int pageSize}) => OrderListResult(
    orders: orders.map((order) => order.toDomain()).toList(),
    total: total,
    page: page,
    pageSize: pageSize,
    hasMore: orders.isNotEmpty && page * pageSize < total,
  );
}

class OrderListOrderModel {
  final Map<String, dynamic> _json;
  final List<OrderListProductModel> products;

  const OrderListOrderModel._(this._json, this.products);

  factory OrderListOrderModel.fromJson(Map<String, dynamic> json) => OrderListOrderModel._(
    json,
    (json['products'] as List? ?? []).map((row) => OrderListProductModel.fromJson(Map<String, dynamic>.from(row as Map))).toList(),
  );

  OrderListOrder toDomain() => OrderListOrder(
    id: _text(_json['orderid']),
    orderNo: _text(_json['ordercode']),
    stateCode: _integer(_json['orderstate']),
    typeCode: _integer(_json['ordertype']),
    stateDescription: _text(_json['orderstatedesc']),
    amountCents: yuanToCents(_json['orderamount']),
    paidAmountCents: yuanToCents(_json['payamount']),
    payAmountDescription: _text(_json['payamountdescr']),
    consumedPoints: _decimal(_json['creditamount'])?.toString(),
    isCreditOrder: _boolean(_json['iscreditorder']),
    createdAt: DateTime.tryParse(_text(_json['createtime']) ?? ''),
    products: products.map((product) => product.toDomain()).toList(),
    actions: [
      if (_json['cancle'] == true) OrderListAction.cancel,
      if (_json['aftersale'] == true) OrderListAction.afterSale,
      if (_json['cancelafter'] == true) OrderListAction.cancelAfterSale,
      if (_json['payment'] == true) OrderListAction.payment,
      if (_json['payend'] == true) OrderListAction.payBalance,
      if (_json['confirm'] == true) OrderListAction.confirm,
      if (_json['evaluate'] == true) OrderListAction.evaluate,
    ],
  );
}

class OrderListProductModel {
  final Map<String, dynamic> _json;
  const OrderListProductModel._(this._json);
  factory OrderListProductModel.fromJson(Map<String, dynamic> json) => OrderListProductModel._(json);

  OrderListProduct toDomain() {
    final parameters = (_json['parameter'] as List? ?? const [])
        .whereType<Map>()
        .map((row) => OrderListParameter(name: _text(row['name']) ?? '', value: _text(row['value']) ?? ''))
        .where((parameter) => parameter.name.isNotEmpty && parameter.value.isNotEmpty)
        .toList(growable: false);

    return OrderListProduct(
      id: _text(_json['pid']),
      name: _text(_json['productname']) ?? _text(_json['pname']),
      image: _text(_json['showimg']) ?? _text(_json['img']),
      priceDescription: _text(_json['description']),
      payAmountDescription: _text(_json['payamountdescr']),
      parameters: parameters,
      priceCents: yuanToCents(_json['shopprice']) ?? yuanToCents(_json['price']),
      creditPrice: _decimal(_json['creditprice'])?.toString(),
      isCreditProduct: _boolean(_json['iscreditproduct']),
      quantity: _integer(_json['num']),
    );
  }
}

String? _text(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _integer(dynamic value) => int.tryParse(value?.toString() ?? '');
Decimal? _decimal(dynamic value) => Decimal.tryParse(value?.toString() ?? '');

bool? _boolean(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

/// 接口金额以元返回；使用十进制换算，避免二进制浮点误差。
int? yuanToCents(dynamic value) {
  final decimal = _decimal(value);
  return decimal == null ? null : (decimal * Decimal.fromInt(100)).round().toBigInt().toInt();
}
