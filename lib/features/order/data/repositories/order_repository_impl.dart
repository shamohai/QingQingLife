import '../../../../core/network/api_response.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

/// 订单列表和订单详情走真实接口；尚未提供接口文档的操作能力继续使用既有实现。
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remote;
  final OrderRepository legacy;

  const OrderRepositoryImpl({required this.remote, required this.legacy});

  @override
  Future<ApiResponse<OrderListResult>> getOrderList({required int page, required int pageSize, int orderState = 0, String keyword = ''}) async {
    final response = await remote.getOrderList(page: page, pageSize: pageSize, orderState: orderState, keyword: keyword);
    return ApiResponse(
      code: response.code,
      message: response.message,
      success: response.success,
      data: response.data?.toDomain(page: page, pageSize: pageSize),
    );
  }

  @override
  Future<ApiResponse<OrderCreateResult>> createOrder({
    required List<OrderItem> items,
    required String addressId,
    required int shippingFeeCents,
    String? couponCode,
    int? pointsToUse,
    String? remark,
  }) => legacy.createOrder(
    items: items,
    addressId: addressId,
    shippingFeeCents: shippingFeeCents,
    couponCode: couponCode,
    pointsToUse: pointsToUse,
    remark: remark,
  );

  @override
  Future<ApiResponse<OrderDetail>> getOrderDetail(String orderId) => remote.getOrderDetail(orderId);

  @override
  Future<ApiResponse<void>> cancelOrder(String orderId, String reason) => remote.cancelOrder(orderId);

  @override
  Future<ApiResponse<void>> confirmReceived(String orderId) => remote.confirmReceived(orderId);

  @override
  Future<ApiResponse<AfterSaleResult>> applyAfterSale({
    required String orderId,
    required String orderItemId,
    required AfterSaleType type,
    required String reason,
    required List<String> images,
    String? description,
  }) => legacy.applyAfterSale(orderId: orderId, orderItemId: orderItemId, type: type, reason: reason, images: images, description: description);

  @override
  Future<ApiResponse<AfterSaleDetail>> getAfterSaleDetail(String afterSaleId) => legacy.getAfterSaleDetail(afterSaleId);

  @override
  Future<ApiResponse<void>> deleteOrder(String orderId) => legacy.deleteOrder(orderId);

  @override
  Future<ApiResponse<void>> rebuy(String orderId) => legacy.rebuy(orderId);

  @override
  Future<ApiResponse<LogisticsInfo>> getLogistics(String orderId) => legacy.getLogistics(orderId);
}
