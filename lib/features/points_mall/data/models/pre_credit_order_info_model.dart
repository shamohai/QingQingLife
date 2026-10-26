import 'service_product_detail_model.dart';

/// 积分商城预下单订单信息接收人类型
enum RecvrType {
  /// 收货地址（实物商品）
  shipAddress(0),

  /// 充值账号或者接收卡密的手机号
  recvrMobile(1),

  /// 不需要接收信息（App 内部卡券）
  none(-1);

  final int value;
  const RecvrType(this.value);

  factory RecvrType.fromValue(dynamic val) {
    if (val == null) return RecvrType.none;
    final v = val is num ? val.toInt() : int.tryParse(val.toString()) ?? -1;
    switch (v) {
      case 0:
        return RecvrType.shipAddress;
      case 1:
        return RecvrType.recvrMobile;
      case -1:
      default:
        return RecvrType.none;
    }
  }
}

/// 积分预下单订单类型
enum OrderType {
  /// 青稞粒/自营积分订单 (SubmitCreditOrder API)
  creditOrder(2),

  /// 服务券兑换订单 (SubmitServiceCouponIntegralOrder API)
  serviceCouponBuyOrder(23),

  /// 百礼汇第三方积分订单 (SubmitBaiLiHuiOrder API)
  baiLiHuiIntegralOrder(25),

  /// 未知订单类型
  unknown(-1);

  final int value;
  const OrderType(this.value);

  factory OrderType.fromValue(dynamic val) {
    if (val == null) return OrderType.unknown;
    final v = val is num ? val.toInt() : int.tryParse(val.toString()) ?? -1;
    switch (v) {
      case 2:
        return OrderType.creditOrder;
      case 23:
        return OrderType.serviceCouponBuyOrder;
      case 25:
        return OrderType.baiLiHuiIntegralOrder;
      default:
        return OrderType.unknown;
    }
  }
}

/// 预下单信息模型 (`LCS__Api__Handler__Order__DealPreCreditOrderInfo`)
class PreCreditOrderInfoModel {
  final RecvrType recvrType;
  final OrderType orderType;
  final int? totalPoints;
  final ServiceProductDetail? product;
  final Map<String, dynamic>? rawData;

  const PreCreditOrderInfoModel({
    required this.recvrType,
    this.orderType = OrderType.unknown,
    this.totalPoints,
    this.product,
    this.rawData,
  });

  factory PreCreditOrderInfoModel.fromJson(Map<String, dynamic> json) {
    final orderObj = (json['order'] ?? json['Order']) as Map<String, dynamic>?;
    final rawRecvrType = orderObj?['recvrtype'] ?? orderObj?['RecvrType'] ?? json['recvrtype'] ?? json['RecvrType'];
    final recvrType = RecvrType.fromValue(rawRecvrType);

    final rawOrderType = orderObj?['ordertype'] ?? orderObj?['OrderType'] ?? json['ordertype'] ?? json['OrderType'];
    final orderType = OrderType.fromValue(rawOrderType);

    final points = (json['totalpoints'] ?? json['TotalPoints'] ?? orderObj?['totalpoints'] ?? orderObj?['TotalPoints']) as int?;

    ServiceProductDetail? productDetail;
    final productsJson = json['products'] ?? json['Products'] ?? json['productlist'] ?? json['ProductList'] ?? orderObj?['products'] ?? orderObj?['Products'];
    if (productsJson is List && productsJson.isNotEmpty) {
      final firstProd = productsJson.first;
      if (firstProd is Map<String, dynamic>) {
        try {
          productDetail = ServiceProductDetail.fromJson(firstProd);
        } catch (_) {}
      }
    } else if (json['product'] is Map<String, dynamic>) {
      try {
        productDetail = ServiceProductDetail.fromJson(json['product'] as Map<String, dynamic>);
      } catch (_) {}
    } else if (orderObj?['product'] is Map<String, dynamic>) {
      try {
        productDetail = ServiceProductDetail.fromJson(orderObj?['product'] as Map<String, dynamic>);
      } catch (_) {}
    }

    return PreCreditOrderInfoModel(
      recvrType: recvrType,
      orderType: orderType,
      totalPoints: points,
      product: productDetail,
      rawData: json,
    );
  }
}
