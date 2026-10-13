import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../product/domain/repositories/product_repository.dart' as repo;
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/providers/repository_providers.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_banner.dart' as home_widgets;
import '../widgets/home_kingkong_grid.dart';
import '../widgets/home_promo_section.dart';
import '../widgets/home_monthly_benefits.dart';
import '../widgets/home_hot_products.dart';
import '../widgets/home_activity_section.dart';
import '../widgets/home_topic_activity_section.dart';
import '../widgets/home_product_showcase.dart';
import '../widgets/home_bottom_nav.dart';

/// 首页静态数据 Provider（轮播、金刚区、新人礼、专题、每月权益、可用商品、活动模块）
final homeStaticDataProvider = FutureProvider<HomeStaticData>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final response = await repository.getHomeProductData();
  if (!response.success || response.data == null) {
    throw Exception(response.message);
  }
  final data = response.data!;
  return HomeStaticData(
    banners: data.banners,
    kingKongItems: data.kingKongItems,
    newUserGifts: data.newUserGifts,
    monthlyBenefits: data.monthlyBenefits,
    hotProducts: data.hotProducts,
    hotSearchKeywords: data.hotSearchKeywords,
    topicActivities: data.topicActivities,
    activityBlocks: data.activityBlocks,
    topicActivityBlocks: data.topicActivityBlocks,
  );
});

/// 首页静态聚合数据
class HomeStaticData {
  final List<repo.HomeBanner> banners;
  final List<repo.HomeKingKongItem> kingKongItems;
  final List<repo.HomeNewUserGift> newUserGifts;
  final List<repo.HomeMonthlyBenefit> monthlyBenefits;
  final List<repo.ProductCard> hotProducts;
  final List<String> hotSearchKeywords;
  final Map<String, String> topicActivities;
  final List<repo.HomeActivityBlock> activityBlocks;
  final List<repo.HomeTopicActivityBlock> topicActivityBlocks;

  const HomeStaticData({
    required this.banners,
    required this.kingKongItems,
    required this.newUserGifts,
    required this.monthlyBenefits,
    required this.hotProducts,
    required this.hotSearchKeywords,
    required this.topicActivities,
    required this.activityBlocks,
    required this.topicActivityBlocks,
  });
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staticDataAsync = ref.watch(homeStaticDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF213775), // 设计稿深蓝背景
      body: staticDataAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stackTrace) => Center(
          child: AppError(message: '加载失败: ', onRetry: () => ref.invalidate(homeStaticDataProvider)),
        ),
        data: (staticData) => CustomScrollView(
          slivers: [
            // 状态栏区域已在 HomeAppBar 中处理
            SliverToBoxAdapter(child: const HomeAppBar()),
            // Banner
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              sliver: SliverToBoxAdapter(child: home_widgets.HomeBanner(imageUrls: staticData.banners.map((b) => b.imageUrl).toList())),
            ),
            // White Card 1: 新人礼 + 可用商品
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: HomePromoSection(gifts: staticData.newUserGifts, products: staticData.hotProducts),
              ),
            ),
            // White Card 2: 金刚区 (10 items, 2x5)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              sliver: SliverToBoxAdapter(child: HomeKingKongGrid(items: staticData.kingKongItems)),
            ),
            // White Card 3: 每月权益
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              sliver: SliverToBoxAdapter(child: HomeMonthlyBenefits(benefits: staticData.monthlyBenefits)),
            ),
            // White Card 4: 热卖商品
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              sliver: SliverToBoxAdapter(child: const HomeHotProducts()),
            ),
            // White Card 5: 线上活动
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              sliver: SliverToBoxAdapter(child: HomeActivitySection(blocks: staticData.activityBlocks)),
            ),
            // White Card 6: 线下活动
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              sliver: SliverToBoxAdapter(child: HomeTopicActivitySection(blocks: staticData.topicActivityBlocks)),
            ),
            // 底部商品展示区
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              sliver: SliverToBoxAdapter(child: HomeProductShowcase(products: staticData.hotProducts)),
            ),
            // 底部导航栏
            const SliverToBoxAdapter(child: HomeBottomNav()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }
}
