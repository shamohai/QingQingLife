import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/order_repository.dart';
import '../../domain/enums/order_type.dart';
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
          id: 'mall_pending_payment',
          orderNo: 'DDBH3456789',
          status: OrderStatus.pendingPayment,
          statusText: '待付款',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.mall,
          createTime: base,
        ),
        OrderSummary(
          id: 'mall_pending_shipment',
          orderNo: 'DDBH3456790',
          status: OrderStatus.pendingShipment,
          statusText: '待发货',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.mall,
          createTime: base,
        ),
        OrderSummary(
          id: 'mall_shipped',
          orderNo: 'DDBH3456791',
          status: OrderStatus.shipped,
          statusText: '待收货/待核销',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.mall,
          createTime: base,
        ),
        OrderSummary(
          id: 'mall_completed_review',
          orderNo: 'DDBH3456792',
          status: OrderStatus.completed,
          statusText: '待评价',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.mall,
          createTime: base,
        ),
        OrderSummary(
          id: 'mall_completed',
          orderNo: 'DDBH3456793',
          status: OrderStatus.completed,
          statusText: '交易完成',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.mall,
          createTime: base,
        ),
        OrderSummary(
          id: 'points_pending_shipment',
          orderNo: 'DDBH3456794',
          status: OrderStatus.pendingShipment,
          statusText: '待发货',
          totalPriceCents: 0,
          productCount: 1,
          orderType: OrderType.points,
          createTime: base,
        ),
        OrderSummary(
          id: 'points_completed_coupon',
          orderNo: 'DDBH3456795',
          status: OrderStatus.completed,
          statusText: '交易完成',
          totalPriceCents: 0,
          productCount: 1,
          orderType: OrderType.points,
          createTime: base,
        ),
        OrderSummary(
          id: 'points_shipped_tour',
          orderNo: 'DDBH3456796',
          status: OrderStatus.shipped,
          statusText: '待核销',
          totalPriceCents: 0,
          productCount: 1,
          orderType: OrderType.points,
          createTime: base,
        ),
        OrderSummary(
          id: 'service_completed',
          orderNo: 'DDBH3456797',
          status: OrderStatus.completed,
          statusText: '交易完成',
          totalPriceCents: 80000,
          productCount: 1,
          orderType: OrderType.service,
          createTime: base,
        ),
      ],
      total: 9,
      page: page,
      pageSize: pageSize,
      hasMore: false,
    );
    return ApiResponse.success(mockOrders);
  }

  @override
  Future<ApiResponse<OrderDetail>> getOrderDetail(String orderId) async {
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
          imageUrl: 'assets/images/product/product1.jpg',
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
