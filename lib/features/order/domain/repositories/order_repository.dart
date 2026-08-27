import '../../../../core/network/api_response.dart';

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

  /// 获取订单列表（分页）
  Future<ApiResponse<OrderListResult>> getOrderList({required int page, required int pageSize, OrderStatus? status});

  /// 获取订单详情
  Future<ApiResponse<OrderDetail>> getOrderDetail(String orderId);

  /// 取消订单
  Future<ApiResponse<void>> cancelOrder(String orderId, String reason);

  /// 确认收货
  Future<ApiResponse<void>> confirmReceived(String orderId);

  /// 申请售后/退款
  Future<ApiResponse<AfterSaleResult>> applyAfterSale({
    required String orderId,
    required String orderItemId,
    required AfterSaleType type,
    required String reason,
    required List<String> images,
    String? description,
  });

  /// 获取售后详情
  Future<ApiResponse<AfterSaleDetail>> getAfterSaleDetail(String afterSaleId);

  /// 删除订单（仅已完成/已取消）
  Future<ApiResponse<void>> deleteOrder(String orderId);

  /// 再次购买
  Future<ApiResponse<void>> rebuy(String orderId);

  /// 获取物流信息
  Future<ApiResponse<LogisticsInfo>> getLogistics(String orderId);
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
  final List<OrderSummary> orders;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const OrderListResult({
    required this.orders,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
}

/// 订单摘要（列表展示）
class OrderSummary {
  final String id;
  final String orderNo;
  final OrderStatus status;
  final String statusText;
  final int totalPriceCents;
  final int productCount;
  final String? firstProductImage;
  final String? firstProductName;
  final DateTime createTime;
  final DateTime? payTime;

  const OrderSummary({
    required this.id,
    required this.orderNo,
    required this.status,
    required this.statusText,
    required this.totalPriceCents,
    required this.productCount,
    this.firstProductImage,
    this.firstProductName,
    required this.createTime,
    this.payTime,
  });
}

/// 订单详情
class OrderDetail {
  final String id;
  final String orderNo;
  final OrderStatus status;
  final String statusText;
  final List<OrderItem> items;
  final OrderAddress address;
  final int productTotalCents;
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
  final String? remark;
  final List<OrderTimeline> timeline;

  const OrderDetail({
    required this.id,
    required this.orderNo,
    required this.status,
    required this.statusText,
    required this.items,
    required this.address,
    required this.productTotalCents,
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
    this.remark,
    required this.timeline,
  });
}

/// 订单商品项
class OrderItem {
  final String id;
  final String productId;
  final String skuId;
  final String productName;
  final String skuName;
  final String imageUrl;
  final int priceCents;
  final int quantity;
  final int totalCents;
  final String? tag;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.skuId,
    required this.productName,
    required this.skuName,
    required this.imageUrl,
    required this.priceCents,
    required this.quantity,
    required this.totalCents,
    this.tag,
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

/// 售后类型
enum AfterSaleType {
  refundOnly('仅退款'),
  returnRefund('退货退款'),
  exchange('换货'),
  repair('维修');

  const AfterSaleType(this.label);
  final String label;
}

/// 售后申请结果
class AfterSaleResult {
  final String afterSaleId;
  final String afterSaleNo;

  const AfterSaleResult({required this.afterSaleId, required this.afterSaleNo});
}

/// 售后详情
class AfterSaleDetail {
  final String id;
  final String afterSaleNo;
  final AfterSaleType type;
  final AfterSaleStatus status;
  final String reason;
  final List<String> images;
  final String? description;
  final int refundAmountCents;
  final DateTime createTime;
  final DateTime? handleTime;
  final String? handleRemark;

  const AfterSaleDetail({
    required this.id,
    required this.afterSaleNo,
    required this.type,
    required this.status,
    required this.reason,
    required this.images,
    this.description,
    required this.refundAmountCents,
    required this.createTime,
    this.handleTime,
    this.handleRemark,
  });
}

/// 售后状态
enum AfterSaleStatus {
  pending('待审核'),
  approved('已通过'),
  rejected('已拒绝'),
  processing('处理中'),
  completed('已完成');

  const AfterSaleStatus(this.label);
  final String label;
}

/// 物流信息
class LogisticsInfo {
  final String company;
  final String trackingNo;
  final List<LogisticsNode> nodes;
  final LogisticsStatus status;

  const LogisticsInfo({required this.company, required this.trackingNo, required this.nodes, required this.status});
}

class LogisticsNode {
  final DateTime time;
  final String description;
  final String? location;

  const LogisticsNode({required this.time, required this.description, this.location});
}

enum LogisticsStatus {
  pending('待揽收'),
  inTransit('运输中'),
  outForDelivery('派送中'),
  delivered('已签收'),
  exception('异常');

  const LogisticsStatus(this.label);
  final String label;
}
