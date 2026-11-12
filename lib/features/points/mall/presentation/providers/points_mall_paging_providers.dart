import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/repository_providers.dart';
import '../../data/models/get_recommend_product_list_model.dart';
import '../../data/models/points_mall_home_data.dart';

/// 热门商品：调用推荐位接口加载；失败时抛出，由页面 Error 状态承接，不降级为假数据。
final pointsMallHotProductsProvider = FutureProvider<List<PointsProduct>>((ref) async {
  final repository = ref.read(pointsRepositoryProvider);
  final response = await repository.getRecommendProductList(positionCode: 'APP_CREDITMALL');
  if (!response.success) {
    throw Exception(response.message);
  }
  return (response.data ?? const <CreditMallProduct>[]).map((item) {
    return PointsProduct(
      id: item.productId.toString(),
      imageUrl: item.imgUrl,
      name: item.productName,
      points: item.creditPrice,
      commentCount: item.commentCount,
      tag: '热门',
      type: item.isService ? PointsProductType.service : PointsProductType.physical,
    );
  }).toList();
});
