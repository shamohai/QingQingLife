import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/service_product_detail_model.dart';

/// 服务商品详情异步 Provider（family：按 productId 加载）
///
/// 第一阶段使用 Mock 数据，第二阶段接入真实 API 时替换 repository 调用。
final serviceProductDetailProvider = FutureProvider.family<ServiceProductDetail, String>((ref, productId) async {
  final repository = ref.read(pointsRepositoryProvider);
  final response = await repository.getServiceProductDetail(productId);
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? '获取服务商品详情失败');
  }
  return response.data!;
});
