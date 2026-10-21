import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/order_repository.dart';
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
  Future<ApiResponse<OrderListResult>> getOrderList({required int page, required int pageSize, int orderState = 0, String keyword = ''}) async {
    return ApiResponse.error('订单列表请使用远程数据源');
  }

  @override
  Future<ApiResponse<OrderDetail>> getOrderDetail(String orderId) async {
    return ApiResponse.error('订单详情请使用远程数据源');
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
      AfterSaleResult(afterSaleId: 'aftersale_${DateTime.now().millisecondsSinceEpoch}', afterSaleNo: 'ASNO${DateTime.now().millisecondsSinceEpoch}'),
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
