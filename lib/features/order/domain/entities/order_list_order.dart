/// 保留后端枚举编码，避免详情页旧的三分类丢失订单类型信息。
enum BackendOrderType {
  oldWine(0, '老酒订单'),
  template(1, '定制酒订单'),
  credit(2, '积分订单'),
  giftCard(3, '礼品卡订单'),
  culturalTemplate(4, '文创定制订单'),
  gift(5, '抽奖礼品订单'),
  closeWine(6, '封坛订单'),
  fuluIntegral(7, '福禄积分订单'),
  ordinary(8, '热销产品订单'),
  serviceCouponSettlement(9, '服务券提货订单'),
  specialSupply(20, '特供订单'),
  groupEquity(21, '合作权益订单'),
  anniversary(22, '特殊纪念订单'),
  serviceCouponBuy(23, '服务券购买订单'),
  baiLiHuiIntegral(25, '百礼汇积分订单');

  const BackendOrderType(this.code, this.label);
  final int code;
  final String label;

  static BackendOrderType? fromCode(int? code) {
    for (final value in values) {
      if (value.code == code) return value;
    }
    return null;
  }
}

enum BackendOrderState {
  all(0, '全部'),
  pendingPayment(30, '待付款'),
  confirming(50, '待确认'),
  confirmRequire(60, '确认需求'),
  pendingShipment(90, '待发货'),
  shipped(110, '待收货'),
  completed(140, '已完成'),
  afterSale(160, '售后'),
  locked(180, '锁定'),
  cancelled(200, '取消'),
  platformCancelled(300, '平台取消');

  const BackendOrderState(this.code, this.label);
  final int code;
  final String label;

  static BackendOrderState? fromCode(int? code) {
    for (final value in values) {
      if (value.code == code) return value;
    }
    return null;
  }
}

enum OrderListAction {
  payment('立即付款', true),
  confirm('确认收货', true),
  cancel('取消订单', false),
  payBalance('支付尾款', true),
  afterSale('申请售后', false),
  cancelAfterSale('取消售后', false);

  const OrderListAction(this.label, this.isPrimary);
  final String label;
  final bool isPrimary;
}

class OrderListOrder {
  final String? id;
  final String? orderNo;
  final int? stateCode;
  final int? typeCode;
  final String? stateDescription;
  final int? amountCents;
  final int? paidAmountCents;
  final String? payAmountDescription;
  final String? consumedPoints;
  final bool? isCreditOrder;
  final DateTime? createdAt;
  final List<OrderListProduct> products;
  final List<OrderListAction> actions;

  const OrderListOrder({
    this.id,
    this.orderNo,
    this.stateCode,
    this.typeCode,
    this.stateDescription,
    this.amountCents,
    this.paidAmountCents,
    this.payAmountDescription,
    this.consumedPoints,
    this.isCreditOrder,
    this.createdAt,
    this.products = const [],
    this.actions = const [],
  });

  String get typeLabel => BackendOrderType.fromCode(typeCode)?.label ?? (typeCode == null ? '未知订单类型' : '未知订单类型（$typeCode）');
  String get statusLabel => stateDescription ?? BackendOrderState.fromCode(stateCode)?.label ?? (stateCode == null ? '未知状态' : '未知状态（$stateCode）');
}

class OrderListProduct {
  final String? id;
  final String? name;
  final String? image;
  final String? priceDescription;
  final String? payAmountDescription;
  final List<OrderListParameter> parameters;
  final int? priceCents;
  final String? creditPrice;
  final bool? isCreditProduct;
  final int? quantity;

  const OrderListProduct({
    this.id,
    this.name,
    this.image,
    this.priceDescription,
    this.payAmountDescription,
    this.parameters = const [],
    this.priceCents,
    this.creditPrice,
    this.isCreditProduct,
    this.quantity,
  });
}

class OrderListParameter {
  final String name;
  final String value;

  const OrderListParameter({required this.name, required this.value});
}
