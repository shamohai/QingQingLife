import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../domain/entities/service_coupon_order.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_detail_response.dart';
import '../models/order_list_response.dart';

/// 统一订单数据源（实现 OrderRepository 接口）
///
/// 仅通过真实后端接口获取数据。接口不存在或请求失败时返回失败结果，
/// 由页面的 Error 状态承接，不伪造成功数据（例如不再返回伪造的订单号）。
class OrderDataSource implements OrderRepository {
  final ApiClient apiClient;

  OrderDataSource({required this.apiClient});

  @override
  Future<ApiResponse<OrderListResult>> getOrderList({required int page, required int pageSize, int orderState = 0, String keyword = ''}) async {
    final search = keyword.trim();
    final isOrderCode = RegExp(r'^[0-9]+$').hasMatch(search);
    final response = await apiClient.post<OrderListResponse>(
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
    if (!response.success) return ApiResponse.error(response.message);
    final data = response.data;
    if (data == null) return ApiResponse.error('');
    return ApiResponse.success(data.toDomain(page: page, pageSize: pageSize));
  }

  /// 普通商品下单：当前项目中没有可用的真实下单接口，返回失败，禁止伪造订单号。
  @override
  Future<ApiResponse<OrderCreateResult>> createOrder({
    required List<OrderItem> items,
    required String addressId,
    required int shippingFeeCents,
    String? couponCode,
    int? pointsToUse,
    String? remark,
  }) async {
    return ApiResponse.error('');
  }

  @override
  Future<ApiResponse<ServiceCouponPreDealData>> preDealServiceCouponOrder({required int serviceCouponId, required int count, int? addressId}) async {
    return apiClient.post<ServiceCouponPreDealData>(
      '/api/order/v2/predealservicecouponorder',
      data: <String, dynamic>{'servicecouponid': serviceCouponId, 'num': count, 'addressid': addressId},
      fromJson: (dynamic json) => ServiceCouponPreDealData.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<ServiceCouponOrderSubmitResult>> submitServiceCouponOrder({
    required int serviceCouponId,
    required int count,
    required int addressId,
    String? remark,
    DateTime? sendTime,
  }) async {
    return apiClient.post<ServiceCouponOrderSubmitResult>(
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

  @override
  Future<ApiResponse<OrderDetail>> getOrderDetail(String orderId) async {
    return apiClient.post<OrderDetail>(
      '/api/order/v2/getorderdetail',
      data: <String, dynamic>{'oid': int.tryParse(orderId) ?? 0},
      fromJson: (dynamic json) => OrderDetailResponse.fromJson(Map<String, dynamic>.from(json as Map)).toDomain(),
    );
  }

  @override
  Future<ApiResponse<void>> cancelOrder(String orderId, [String? reason]) async {
    return apiClient.post<void>('/api/order/cancelorder', data: <String, dynamic>{'orderid': int.tryParse(orderId) ?? 0});
  }

  @override
  Future<ApiResponse<void>> confirmReceived(String orderId) async {
    return apiClient.post<void>('/api/order/orderreceipt', data: <String, dynamic>{'orderid': int.tryParse(orderId) ?? 0});
  }
}

final orderDataSourceProvider = Provider<OrderDataSource>((ref) {
  return OrderDataSource(apiClient: ref.read(apiClientProvider));
});
