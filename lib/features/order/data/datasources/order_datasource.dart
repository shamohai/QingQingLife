import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../domain/entities/service_coupon_order.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_detail_response.dart';
import '../models/order_list_response.dart';

/// 统一订单数据源（实现 OrderRepository 接口）
class OrderDataSource implements OrderRepository {
  final ApiClient? _apiClient;

  OrderDataSource({this._apiClient});

  @override
  Future<ApiResponse<OrderListResult>> getOrderList({required int page, required int pageSize, int orderState = 0, String keyword = ''}) async {
    final client = _apiClient;
    if (client != null) {
      try {
        final search = keyword.trim();
        final isOrderCode = RegExp(r'^[0-9]+$').hasMatch(search);
        final response = await client.post<OrderListResponse>(
          '/api/order/getorderlist',
          data: <String, dynamic>{
            'orderstate': orderState,
            'ordercode': search.isNotEmpty && isOrderCode ? search : null,
            'productname': search.isNotEmpty && !isOrderCode ? search : null,
            'pageindex': page,
            'pagesize': pageSize,
          },
          fromJson: (dynamic json) => OrderListResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        );
        if (response.success && response.data != null) {
          return ApiResponse(
            code: response.code,
            message: response.message,
            success: response.success,
            data: response.data!.toDomain(page: page, pageSize: pageSize),
          );
        }
      } catch (_) {}
    }
    return ApiResponse.success(OrderListResult(orders: [], total: 0, page: page, pageSize: pageSize, hasMore: false));
  }

  @override
  Future<ApiResponse<OrderCreateResult>> createOrder({
    required List<OrderItem> items,
    required String addressId,
    required int shippingFeeCents,
    String? couponCode,
    int? pointsToUse,
    String? remark,
  }) async {
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
  Future<ApiResponse<ServiceCouponPreDealData>> preDealServiceCouponOrder({required int serviceCouponId, required int count, int? addressId}) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<ServiceCouponPreDealData>(
        '/api/order/v2/predealservicecouponorder',
        data: <String, dynamic>{'servicecouponid': serviceCouponId, 'num': count, 'addressid': addressId},
        fromJson: (dynamic json) => ServiceCouponPreDealData.fromJson(Map<String, dynamic>.from(json as Map)),
      );
    }
    return ApiResponse.error('接口未配置');
  }

  @override
  Future<ApiResponse<ServiceCouponOrderSubmitResult>> submitServiceCouponOrder({
    required int serviceCouponId,
    required int count,
    required int addressId,
    String? remark,
    DateTime? sendTime,
  }) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<ServiceCouponOrderSubmitResult>(
        '/api/order/v2/submitservicecouponorder',
        data: <String, dynamic>{
          'servicecouponid': serviceCouponId,
          'num': count,
          'addressid': addressId,
          'remark': remark,
          'sendtime': sendTime?.toIso8601String(),
        },
        fromJson: (dynamic json) => ServiceCouponOrderSubmitResult.fromJson(Map<String, dynamic>.from(json as Map)),
      );
    }
    return ApiResponse.error('接口未配置');
  }

  @override
  Future<ApiResponse<OrderDetail>> getOrderDetail(String orderId) async {
    final client = _apiClient;
    if (client != null) {
      try {
        return await client.post<OrderDetail>(
          '/api/order/v2/getorderdetail',
          data: <String, dynamic>{'oid': int.tryParse(orderId) ?? 0},
          fromJson: (dynamic json) => OrderDetailResponse.fromJson(Map<String, dynamic>.from(json as Map)).toDomain(),
        );
      } catch (_) {}
    }
    return ApiResponse.error('未找到该订单');
  }

  @override
  Future<ApiResponse<void>> cancelOrder(String orderId, [String? reason]) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<void>('/api/order/cancelorder', data: <String, dynamic>{'orderid': int.tryParse(orderId) ?? 0});
    }
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> confirmReceived(String orderId) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<void>('/api/order/orderreceipt', data: <String, dynamic>{'orderid': int.tryParse(orderId) ?? 0});
    }
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
        description: '仅退款服务',
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
        company: '顺丰速运',
        trackingNo: 'SF1234567890',
        nodes: [
          LogisticsNode(time: DateTime.now().subtract(const Duration(days: 1)), description: '揽收', location: '北京'),
          LogisticsNode(time: DateTime.now(), description: '运输中', location: '上海'),
        ],
        status: LogisticsStatus.inTransit,
      ),
    );
  }
}

final orderDataSourceProvider = Provider<OrderDataSource>((ref) {
  return OrderDataSource(apiClient: ref.read(apiClientProvider));
});
