/// 积分商城商品分类 Provider
///
/// 调用 GetCreditProductCategory 接口，返回含"全部分类"（categoryId=0）的完整列表。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/repository_providers.dart';
import '../../data/models/credit_product_category_model.dart';

final creditProductCategoryProvider = FutureProvider<CreditProductCategoryData>((ref) async {
  final repository = ref.read(pointsRepositoryProvider);
  final response = await repository.getCreditProductCategory();
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data!;
});
