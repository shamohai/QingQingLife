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
  final int credit;
  final int redeemableQuantity;

  /// 默认充值账号（虚拟产品），对应接口字段 defaultrechargemobile
  final String defaultRechargeMobile;
  final ServiceProductDetail? product;
  final Map<String, dynamic>? rawData;

  const PreCreditOrderInfoModel({
    required this.recvrType,
    this.orderType = OrderType.unknown,
    this.totalPoints,
    this.credit = 0,
    this.redeemableQuantity = 0,
    this.defaultRechargeMobile = '',
    this.product,
    this.rawData,
  });

  factory PreCreditOrderInfoModel.fromJson(Map<String, dynamic> json) {
    final orderObj = _map(json['order'] ?? json['Order']);
    final stores = _mapList(json['stores'] ?? json['Stores'] ?? orderObj?['stores'] ?? orderObj?['Stores']);
    final products = stores.expand((store) => _mapList(store['products'] ?? store['Products'])).toList();
    final firstProduct = products.isNotEmpty ? products.first : _map(json['product'] ?? orderObj?['product']);

    final rawRecvrType = orderObj?['recvrtype'] ?? orderObj?['RecvrType'] ?? json['recvrtype'] ?? json['RecvrType'];
    final rawOrderType = orderObj?['ordertype'] ?? orderObj?['OrderType'] ?? json['ordertype'] ?? json['OrderType'];
    final credit = _toInt(json['credit'] ?? json['Credit'] ?? orderObj?['credit'] ?? orderObj?['Credit']);
    final quantity = _toInt(firstProduct?['num'] ?? firstProduct?['Num'] ?? json['num'] ?? json['Num']);
    final creditCount = _toInt(firstProduct?['creditcount'] ?? firstProduct?['CreditCount']);
    final rawTotalPoints = _toInt(json['totalpoints'] ?? json['TotalPoints'] ?? orderObj?['totalpoints'] ?? orderObj?['TotalPoints']);
    final totalPoints = rawTotalPoints > 0 ? rawTotalPoints : creditCount * (quantity > 0 ? quantity : 1);

    ServiceProductDetail? productDetail;
    if (firstProduct != null) {
      productDetail = ServiceProductDetail.fromJson(<String, dynamic>{
        ...firstProduct,
        'pid': firstProduct['pid'] ?? firstProduct['productid'] ?? firstProduct['itemid'],
        'name': firstProduct['name'] ?? firstProduct['productname'] ?? '',
        'price': firstProduct['price'] ?? firstProduct['creditcount'] ?? 0,
        'marketprice': firstProduct['marketprice'] ?? 0,
        'carouselimg': _imageList(firstProduct['imgurl'] ?? firstProduct['ImgUrl'] ?? firstProduct['carouselimg']),
        'stocknum': firstProduct['num'] ?? firstProduct['Num'] ?? 0,
        'creditcount': firstProduct['creditcount'] ?? firstProduct['CreditCount'] ?? 0,
        'iscredit': true,
      });
    }

    return PreCreditOrderInfoModel(
      recvrType: RecvrType.fromValue(rawRecvrType),
      orderType: OrderType.fromValue(rawOrderType),
      totalPoints: totalPoints,
      credit: credit,
      redeemableQuantity: quantity,
      defaultRechargeMobile: _string(json['defaultrechargemobile'] ?? json['DefaultRechargeMobile']),
      product: productDetail,
      rawData: json,
    );
  }

  static String _string(dynamic value) => value == null ? '' : value.toString().trim();

  static Map<String, dynamic>? _map(dynamic value) => value is Map ? Map<String, dynamic>.from(value) : null;

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static int _toInt(dynamic value) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

  static List<String> _imageList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    final image = value?.toString() ?? '';
    return image.isEmpty ? const [] : [image];
  }
}
