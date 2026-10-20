import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
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
}

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) => OrderRemoteDataSource(ref.read(apiClientProvider)));
