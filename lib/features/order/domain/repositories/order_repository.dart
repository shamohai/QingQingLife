import '../../../../core/network/api_response.dart';
import '../enums/order_type.dart';
import '../entities/order_list_order.dart';
import '../entities/service_coupon_order.dart';

/// 订单仓库接口
abstract class OrderRepository {
  /// 创建订单（结算页提交）
  Future<ApiResponse<OrderCreateResult>> createOrder({
    required List<OrderItem> items,
    required String addressId,
    required int shippingFeeCents,
    String? couponCode,
    int? pointsToUse,
    String? remark,
  });

  /// 预处理服务券订单（真实接口：POST /api/order/v2/predealservicecouponorder）
  Future<ApiResponse<ServiceCouponPreDealData>> preDealServiceCouponOrder({required int serviceCouponId, required int count, int? addressId});

  /// 提交服务券订单（真实接口：POST /api/order/v2/submitservicecouponorder）
  Future<ApiResponse<ServiceCouponOrderSubmitResult>> submitServiceCouponOrder({
    required int serviceCouponId,
    required int count,
    required int addressId,
    String? remark,
    DateTime? sendTime,
  });

  /// 获取订单列表（分页）
  Future<ApiResponse<OrderListResult>> getOrderList({required int page, required int pageSize, int orderState = 0, String keyword = ''});

  /// 获取订单详情
  Future<ApiResponse<OrderDetail>> getOrderDetail(String orderId);

  /// 取消订单
  Future<ApiResponse<void>> cancelOrder(String orderId, String reason);

  /// 确认收货
  Future<ApiResponse<void>> confirmReceived(String orderId);
}

/// 订单创建结果
class OrderCreateResult {
  final String orderId;
  final String orderNo;
  final int payAmountCents;
  final String? prepayId; // 微信支付 prepay_id

  const OrderCreateResult({required this.orderId, required this.orderNo, required this.payAmountCents, this.prepayId});
}

/// 订单列表分页结果
class OrderListResult {
  final List<OrderListOrder> orders;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const OrderListResult({required this.orders, required this.total, required this.page, required this.pageSize, required this.hasMore});
}

/// 订单详情
class OrderDetail {
  final String id;
  final String orderNo;
  final OrderStatus status;
  final int? backendStateCode;
  final String statusText;
  final int? backendTypeCode;
  final String? orderTypeLabel;
  final bool isCreditOrder;
  final List<OrderItem> items;
  final OrderAddress address;
  final int productTotalCents;
  final String? orderAmountDescription;
  final int shippingFeeCents;
  final int discountCents;
  final int pointsDeductedCents;
  final int payAmountCents;
  final String? couponName;
  final DateTime createTime;
  final DateTime? payTime;
  final DateTime? shipTime;
  final DateTime? receiveTime;
  final String? logisticsCompany;
  final String? logisticsNo;
  final List<OrderTimeline> timeline;
  final OrderType? orderType;
  final int? pointsCost;
  final DateTime? exchangeTime;
  final String? pickupCode;
  final String? payAmountDescription;
  final String? payTypeName;
  final String? paySerialNumber;
  final String? mobile;
  final int? payIntegralCount;
  final String? userRemark;
  final bool canCancel;
  final bool canCancelAfterSale;
  final bool canComment;
  final bool canReceive;
  final bool canAfterSale;
  final bool waitPay;
  final bool waitEndPay;

  /// 百礼汇产品类型（API: baiLiHuiType）：0 自营实物、1 电子卡券、2 直充话费、3 电商。
  /// 无值时为 null。
  final int? baiLiHuiType;

  const OrderDetail({
    required this.id,
    required this.orderNo,
    required this.status,
    this.backendStateCode,
    required this.statusText,
    this.backendTypeCode,
    this.orderTypeLabel,
    this.isCreditOrder = false,
    required this.items,
    required this.address,
    this.mobile,
    required this.productTotalCents,
    this.orderAmountDescription,
    required this.shippingFeeCents,
    required this.discountCents,
    required this.pointsDeductedCents,
    required this.payAmountCents,
    this.couponName,
    required this.createTime,
    this.payTime,
    this.shipTime,
    this.receiveTime,
    this.logisticsCompany,
    this.logisticsNo,
    required this.timeline,
    this.orderType,
    this.pointsCost,
    this.payIntegralCount,
    this.exchangeTime,
    this.pickupCode,
    this.payAmountDescription,
    this.payTypeName,
    this.paySerialNumber,
    this.userRemark,
    this.baiLiHuiType,
    this.canCancel = false,
    this.canCancelAfterSale = false,
    this.canComment = false,
    this.canReceive = false,
    this.canAfterSale = false,
    this.waitPay = false,
    this.waitEndPay = false,
  });

  /// 是否为虚拟商品（电子卡券、直充话费）。
  ///
  /// 仅当 baiLiHuiType 有值且为 1 或 2 时为 true；
  /// 字段无值（null）时按非虚拟处理，保持默认展示。
  bool get isVirtualGoods => baiLiHuiType == 1 || baiLiHuiType == 2;
}

/// 订单商品项
class OrderItem {
  final String id;
  final String productId;
  final String skuId;
  final String productName;
  final String skuName;
  final String? priceDescription;
  final List<OrderListParameter> parameters;
  final String imageUrl;
  final int priceCents;
  final int quantity;
  final int totalCents;
  final String? tag;
  final String? payAmountDescription;
  final bool isGift;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.skuId,
    required this.productName,
    required this.skuName,
    this.priceDescription,
    this.parameters = const [],
    required this.imageUrl,
    required this.priceCents,
    required this.quantity,
    required this.totalCents,
    this.tag,
    this.payAmountDescription,
    this.isGift = false,
  });
}

/// 收货地址
class OrderAddress {
  final String id;
  final String name;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String detail;
  final String fullAddress;

  const OrderAddress({
    required this.id,
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    required this.fullAddress,
  });
}

/// 订单时间线
class OrderTimeline {
  final DateTime time;
  final String title;
  final String? desc;
  final OrderStatus status;

  const OrderTimeline({required this.time, required this.title, this.desc, required this.status});
}

/// 订单状态枚举
enum OrderStatus {
  pendingPayment('待付款'),
  pendingShipment('待发货'),
  shipped('待收货'),
  completed('已完成'),
  cancelled('已取消'),
  refunding('退款中'),
  refunded('已退款');

  const OrderStatus(this.label);
  final String label;
}
