import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/order_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/providers/repository_providers.dart';

/// 订单详情真实数据 Provider。
final orderDetailProvider = FutureProvider.family<ApiResponse<OrderDetail>, String>((ref, id) {
  return ref.read(orderRepositoryProvider).getOrderDetail(id);
});
