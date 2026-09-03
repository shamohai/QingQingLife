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
import '../widgets/home_branding_footer.dart';
import '../widgets/home_product_grid.dart';

/// 首页静态数据 Provider（轮播、金刚区、新人礼、专题、每月权益、可用商品、活动模块）
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
    monthlyBenefits: data.monthlyBenefits,
    hotProducts: data.hotProducts,
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
  final Map<String, String> topicActivities;
  final List<repo.HomeActivityBlock> activityBlocks;
  final List<repo.HomeTopicActivityBlock> topicActivityBlocks;

  const HomeStaticData({
    required this.banners,
    required this.kingKongItems,
    required this.newUserGifts,
    required this.monthlyBenefits,
    required this.hotProducts,
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
      body: staticDataAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stackTrace) => Center(
          child: AppError(message: '加载失败: ', onRetry: () => ref.invalidate(homeStaticDataProvider)),
        ),
        data: (staticData) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: const HomeAppBar()),
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: home_widgets.HomeBanner(imageUrls: staticData.banners.map((b) => b.imageUrl).toList()),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: HomePromoSection(
                  gifts: staticData.newUserGifts,
                  products: staticData.hotProducts,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              sliver: SliverToBoxAdapter(
                child: HomeKingKongGrid(items: staticData.kingKongItems),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: HomeMonthlyBenefits(benefits: staticData.monthlyBenefits),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: const HomeHotProducts(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: HomeActivitySection(blocks: staticData.activityBlocks),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: HomeTopicActivitySection(blocks: staticData.topicActivityBlocks),
              ),
            ),
            const SliverToBoxAdapter(
              child: HomeBrandingFooter(),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: const HomeProductGrid(),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }
}
