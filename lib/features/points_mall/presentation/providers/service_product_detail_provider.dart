import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/service_product_detail_model.dart';

/// 服务商品详情异步 Provider（family：按 productId 加载）
///
/// autoDispose：页面销毁时自动释放，避免 navigate back 时异步重建触发 build scope 错误。
final serviceProductDetailProvider =
    FutureProvider.family.autoDispose<ServiceProductDetail, String>((ref, productId) async {
  final repository = ref.read(pointsRepositoryProvider);
  final response = await repository.getServiceProductDetail(productId);
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? '获取服务商品详情失败');
  }
  return response.data!;
});
