import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/order_repository.dart';
import '../../../../core/network/api_response.dart';

/// Mock 订单数据源 - 开发/测试环境使用
class MockOrderDataSource implements OrderRepository {
  // Mock 订单状态枚举（与抽象类同步）
  static const _statuses = [
    OrderStatus.pendingPayment,
    OrderStatus.pendingShipment,
    OrderStatus.shipped,
    OrderStatus.completed,
    OrderStatus.cancelled,
  ];

  @override
  Future<ApiResponse<OrderCreateResult>> createOrder({
    required List<OrderItem> items,
    required String addressId,
    required int shippingFeeCents,
    String? couponCode,
    int? pointsToUse,
    String? remark,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

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
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock 订单列表
    final mockOrders = OrderListResult(
      orders: [
        OrderSummary(
          id: 'o1',
          orderNo: 'NO20240101001',
          status: OrderStatus.pendingPayment,
          statusText: '待付款',
          totalPriceCents: 13990,
          productCount: 1,
          createTime: DateTime.now().subtract(const Duration(days: 1)),
        ),
        OrderSummary(
          id: 'o2',
          orderNo: 'NO20240102002',
          status: OrderStatus.pendingShipment,
          statusText: '待发货',
          totalPriceCents: 25800,
          productCount: 2,
          createTime: DateTime.now().subtract(const Duration(days: 2)),
        ),
        OrderSummary(
          id: 'o3',
          orderNo: 'NO20240103003',
          status: OrderStatus.shipped,
          statusText: '待收货',
          totalPriceCents: 9800,
          productCount: 1,
          createTime: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ],
      total: 3,
      page: page,
      pageSize: pageSize,
      hasMore: false,
    );

    return ApiResponse.success(mockOrders);
  }

  @override
  Future<ApiResponse<OrderDetail>> getOrderDetail(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final mockDetail = OrderDetail(
      id: orderId,
      orderNo: 'NO20240104004',
      status: OrderStatus.pendingShipment,
      statusText: '待发货',
      items: [
        OrderItem(
          id: 'oi_1',
          productId: '1',
          skuId: 'sku_1',
          productName: '天佑德电商专供海拔系列 2900青稞酒 46度500ml',
          skuName: '500ml 单瓶',
          imageUrl: 'https://picsum.photos/300/300?random=10',
          priceCents: 13990,
          quantity: 2,
          totalCents: 27980,
        ),
      ],
      address: OrderAddress(
        id: 'addr_1',
        name: '张三',
        phone: '13800138000',
        province: '北京',
        city: '北京',
        district: '朝阳区',
        detail: '朝阳路 1 号',
        fullAddress: '北京市朝阳区朝阳路 1 号',
      ),
      productTotalCents: 13990,
      shippingFeeCents: 500,
      discountCents: 0,
      pointsDeductedCents: 0,
      payAmountCents: 14490,
      couponName: null,
      createTime: DateTime.now().subtract(const Duration(days: 1)),
      payTime: null,
      shipTime: null,
      receiveTime: null,
      logisticsCompany: '顺丰速递',
      logisticsNo: 'SF1234567890',
      remark: null,
      timeline: [
        OrderTimeline(
          time: DateTime.now().subtract(const Duration(days: 1)),
          title: '下单',
          desc: '下单成功',
          status: OrderStatus.pendingPayment,
        ),
        OrderTimeline(
          time: DateTime.now().subtract(const Duration(days: 0, hours: 2)),
          title: '支付',
          desc: '已支付',
          status: OrderStatus.pendingPayment,
        ),
        OrderTimeline(time: DateTime.now(), title: '发货', desc: '已发货', status: OrderStatus.pendingShipment),
      ],
    );

    return ApiResponse.success(mockDetail);
  }

  @override
  Future<ApiResponse<void>> cancelOrder(String orderId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> confirmReceived(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
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
    await Future.delayed(const Duration(milliseconds: 800));

    return ApiResponse.success(
      AfterSaleResult(
        afterSaleId: 'aftersale_${DateTime.now().millisecondsSinceEpoch}',
        afterSaleNo: 'ASNO${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  @override
  Future<ApiResponse<AfterSaleDetail>> getAfterSaleDetail(String afterSaleId) async {
    await Future.delayed(const Duration(milliseconds: 500));

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
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> rebuy(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<LogisticsInfo>> getLogistics(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 400));

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
