import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../product/domain/repositories/product_repository.dart' as repo;
import '../../../../core/network/api_response.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/providers/repository_providers.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_banner.dart' as home_widgets;
import '../widgets/home_kingkong_grid.dart';
import '../widgets/home_new_user_gift_card.dart';
import '../widgets/home_hot_products.dart';
import '../widgets/home_topic_banner.dart';
import '../widgets/home_product_grid.dart';
import '../providers/home_provider.dart';
import '../providers/home_paging_providers.dart';

/// 首页静态数据（轮播、金刚区、新人礼、专题活动）Provider
final homeStaticDataProvider = FutureProvider<HomeStaticData>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final response = await repository.getHomeProductData();
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? '获取首页数据失败');
  }
  final data = response.data!;
  return HomeStaticData(
    banners: data.banners,
    kingKongItems: data.kingKongItems,
    newUserGifts: data.newUserGifts,
    topicActivities: data.topicActivities,
  );
});

/// 首页静态聚合数据（不含分页商品列表）
class HomeStaticData {
  final List<repo.HomeBanner> banners;
  final List<repo.HomeKingKongItem> kingKongItems;
  final List<repo.HomeNewUserGift> newUserGifts;
  final Map<String, String> topicActivities;

  const HomeStaticData({
    required this.banners,
    required this.kingKongItems,
    required this.newUserGifts,
    required this.topicActivities,
  });
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staticDataAsync = ref.watch(homeStaticDataProvider);

    return Scaffold(
      body: staticDataAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stackTrace) => Center(
          child: AppError(message: '加载失败: $error', onRetry: () => ref.invalidate(homeStaticDataProvider)),
        ),
        data: (staticData) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: HomeAppBar()),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: home_widgets.HomeBanner(imageUrls: staticData.banners.map((b) => b.imageUrl).toList()),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  HomeKingKongGrid(items: staticData.kingKongItems),
                  const SizedBox(height: AppSpacing.lg),
                  HomeNewUserGiftCard(gifts: staticData.newUserGifts),
                  const SizedBox(height: AppSpacing.lg),
                  HomeHotProducts(), // 现在内部自带分页
                  const SizedBox(height: AppSpacing.lg),
                  HomeTopicBanner(topics: staticData.topicActivities),
                  const SizedBox(height: AppSpacing.lg),
                  HomeProductGrid(), // 现在内部自带分页
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
