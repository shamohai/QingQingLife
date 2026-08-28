import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/providers/repository_providers.dart';

/// 首页聚合数据模型
class HomeData {
  final List<HomeBanner> banners;
  final List<HomeKingKongItem> kingKongItems;
  final List<HomeNewUserGift> newUserGifts;
  final List<ProductCard> hotProducts;
  final Map<String, String> topicActivities;
  final List<HomeMonthlyBenefit> monthlyBenefits;

  const HomeData({
    required this.banners,
    required this.kingKongItems,
    required this.newUserGifts,
    required this.hotProducts,
    required this.topicActivities,
    required this.monthlyBenefits,
  });
}

/// 首页数据异步 Provider - 通过 Repository 获取数据
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final response = await repository.getHomeProductData();

  if (!response.success || response.data == null) {
    throw Exception(response.message ?? '获取首页数据失败');
  }

  final data = response.data!;
  return HomeData(
    banners: data.banners,
    kingKongItems: data.kingKongItems,
    newUserGifts: data.newUserGifts,
    hotProducts: data.hotProducts,
    topicActivities: data.topicActivities,
    monthlyBenefits: data.monthlyBenefits,
  );
});