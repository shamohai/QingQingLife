import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/order_repository.dart';
import '../../domain/enums/order_type.dart';
import '../../presentation/providers/order_detail_provider.dart';
import '../../../../core/network/api_response.dart';

/// Mock 订单数据源 - 开发/测试环境使用
class MockOrderDataSource implements OrderRepository {
  @override
  Future<ApiResponse<OrderCreateResult>> createOrder({
    required List<OrderItem> items,
    required String addressId,
    required int shippingFeeCents,
    String? couponCode,
    int? pointsToUse,
    String? remark,
  }) async {
    // Mock 返回新订单
    final mockOrderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
    final mockOrderNo = 'NO${DateTime.now().millisecondsSinceEpoch}';
    final totalAmount = items.fold(0, (sum, item) => sum + item.totalCents);

    return ApiResponse.success(
      OrderCreateResult(
        orderId: mockOrderId,
        orderNo: mockOrderNo,
        payAmountCents: totalAmount + shippingFeeCents,
        prepayId: 'prepay_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  @override
  Future<ApiResponse<OrderListResult>> getOrderList({
    required int page,
    required int pageSize,
    OrderStatus? status,
  }) async {
    final base = DateTime(2026, 10, 10, 12, 12, 11);
    final mockOrders = OrderListResult(
      orders: [
        OrderSummary(
          id: '1',
          orderNo: 'DDBH3456789',
          status: OrderStatus.completed,
          statusText: '交易完成',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.service,
          createTime: base,
        ),
        OrderSummary(
          id: '2',
          orderNo: 'DDBH3456789',
          status: OrderStatus.completed,
          statusText: '交易完成',
          totalPriceCents: 0,
          productCount: 1,
          orderType: OrderType.points,
          createTime: base,
        ),
        OrderSummary(
          id: '3',
          orderNo: 'DDBH3456789',
          status: OrderStatus.pendingShipment,
          statusText: '待发货',
          totalPriceCents: 0,
          productCount: 1,
          orderType: OrderType.points,
          createTime: base,
        ),
        OrderSummary(
          id: '4',
          orderNo: 'DDBH3456789',
          status: OrderStatus.shipped,
          statusText: '待收货/待核销',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.service,
          createTime: base,
        ),
        OrderSummary(
          id: '5',
          orderNo: 'DDBH3456789',
          status: OrderStatus.completed,
          statusText: '待评价',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.mall,
          createTime: base,
        ),
        OrderSummary(
          id: '6',
          orderNo: 'DDBH3456789',
          status: OrderStatus.completed,
          statusText: '交易完成',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.mall,
          createTime: base,
        ),
        OrderSummary(
          id: '7',
          orderNo: 'DDBH3456789',
          status: OrderStatus.completed,
          statusText: '待评价',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.mall,
          createTime: base,
        ),
        OrderSummary(
          id: '8',
          orderNo: 'DDBH3456789',
          status: OrderStatus.shipped,
          statusText: '待收货/待核销',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.mall,
          createTime: base,
        ),
        OrderSummary(
          id: '9',
          orderNo: 'DDBH3456789',
          status: OrderStatus.pendingShipment,
          statusText: '待发货',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.mall,
          createTime: base,
        ),
        OrderSummary(
          id: '10',
          orderNo: 'DDBH3456789',
          status: OrderStatus.pendingPayment,
          statusText: '待付款',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.mall,
          createTime: base,
        ),
      ],
      total: 10,
      page: page,
      pageSize: pageSize,
      hasMore: false,
    );
    return ApiResponse.success(mockOrders);
  }

  @override
  Future<ApiResponse<OrderDetail>> getOrderDetail(String orderId) async {
    return ApiResponse.success(getMockOrderDetail(orderId));
  }

  @override
  Future<ApiResponse<void>> cancelOrder(String orderId, String reason) async {
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> confirmReceived(String orderId) async {
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<AfterSaleResult>> applyAfterSale({
    required String orderId,
    required String orderItemId,
    required AfterSaleType type,
    required String reason,
    required List<String> images,
    String? description,
  }) async {
    return ApiResponse.success(
      AfterSaleResult(
        afterSaleId: 'aftersale_${DateTime.now().millisecondsSinceEpoch}',
        afterSaleNo: 'ASNO${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  @override
  Future<ApiResponse<AfterSaleDetail>> getAfterSaleDetail(String afterSaleId) async {
    return ApiResponse.success(
      AfterSaleDetail(
        id: afterSaleId,
        afterSaleNo: 'ASNO001',
        type: AfterSaleType.refundOnly,
        status: AfterSaleStatus.pending,
        reason: '用户申请退款',
        images: [],
        description: '用户申请仅退款',
        refundAmountCents: 13990,
        createTime: DateTime.now(),
        handleTime: null,
        handleRemark: null,
      ),
    );
  }

  @override
  Future<ApiResponse<void>> deleteOrder(String orderId) async {
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> rebuy(String orderId) async {
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<LogisticsInfo>> getLogistics(String orderId) async {
    return ApiResponse.success(
      LogisticsInfo(
        company: '顺丰速递',
        trackingNo: 'SF1234567890',
        nodes: [
          LogisticsNode(time: DateTime.now().subtract(const Duration(days: 1)), description: '揽收', location: '北京'),
          LogisticsNode(time: DateTime.now(), description: '运输中', location: '上海'),
          LogisticsNode(time: DateTime.now().add(const Duration(hours: 1)), description: '派送中', location: '目的地'),
          LogisticsNode(time: DateTime.now().add(const Duration(hours: 3)), description: '已签收', location: '目的地'),
        ],
        status: LogisticsStatus.delivered,
      ),
    );
  }
}

/// MockOrderRepository Provider - 开发环境使用
final mockOrderRepositoryProvider = Provider<OrderRepository>((ref) => MockOrderDataSource());
