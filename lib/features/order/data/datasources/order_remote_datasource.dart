import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_detail_response.dart';
import '../models/order_list_response.dart';

class OrderRemoteDataSource {
  final ApiClient _apiClient;
  const OrderRemoteDataSource(this._apiClient);

  Future<ApiResponse<OrderListResponse>> getOrderList({required int page, required int pageSize, required int orderState, String keyword = ''}) {
    final search = keyword.trim();
    final isOrderCode = RegExp(r'^[0-9]+$').hasMatch(search);
    return _apiClient.post<OrderListResponse>(
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
  }

  Future<ApiResponse<OrderDetail>> getOrderDetail(String orderId) {
    return _apiClient.post<OrderDetail>(
      '/api/order/v2/getorderdetail',
      data: <String, dynamic>{'oid': int.tryParse(orderId) ?? 0},
      fromJson: (dynamic json) => OrderDetailResponse.fromJson(Map<String, dynamic>.from(json as Map)).toDomain(),
    );
  }

  Future<ApiResponse<void>> cancelOrder(String orderId) {
    return _apiClient.post<void>('/api/order/cancelorder', data: <String, dynamic>{'orderid': int.tryParse(orderId) ?? 0});
  }

  Future<ApiResponse<void>> confirmReceived(String orderId) {
    return _apiClient.post<void>('/api/order/orderreceipt', data: <String, dynamic>{'orderid': int.tryParse(orderId) ?? 0});
  }
}

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) => OrderRemoteDataSource(ref.read(apiClientProvider)));
