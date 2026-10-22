import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qingqinglife/app/theme/app_spacing.dart';
import 'package:qingqinglife/features/points_mall/presentation/widgets/points_floating_buttons.dart';

import '../../../product/domain/repositories/product_repository.dart' as repo;
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/providers/repository_providers.dart';
import '../widgets/home_banner.dart' as home_widgets;
import '../widgets/home_kingkong_grid.dart';
import '../widgets/home_promo_section.dart';
import '../widgets/home_monthly_benefits.dart';
import '../widgets/home_hot_products.dart';
import '../widgets/home_activity_section.dart';
import '../widgets/home_topic_activity_section.dart';
import '../widgets/home_bottom_recommend_section.dart';
import '../../data/providers/home_carousel_provider.dart';
import '../providers/home_paging_providers.dart';

/// 首页静态数据 Provider（金刚区、新人礼、专题、每月权益、可用商品、活动模块）
/// 轮播图由独立的 homeCarouselProvider 提供
final homeStaticDataProvider = FutureProvider<HomeStaticData>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final response = await repository.getHomeProductData();
  if (!response.success || response.data == null) {
    throw Exception(response.message);
  }
  final data = response.data!;
  return HomeStaticData(
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
  final List<repo.HomeKingKongItem> kingKongItems;
  final List<repo.HomeNewUserGift> newUserGifts;
  final List<repo.HomeMonthlyBenefit> monthlyBenefits;
  final List<repo.ProductCard> hotProducts;
  final List<String> hotSearchKeywords;
  final Map<String, String> topicActivities;
  final List<repo.HomeActivityBlock> activityBlocks;
  final List<repo.HomeTopicActivityBlock> topicActivityBlocks;

  const HomeStaticData({
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
    final carouselAsync = ref.watch(homeCarouselProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF213775),
      body: Stack(
        children: [
          staticDataAsync.when(
            loading: () => const Center(child: AppLoading()),
            error: (error, stackTrace) => Center(
              child: AppError(message: '加载失败: $error', onRetry: () => ref.invalidate(homeStaticDataProvider)),
            ),
            data: (staticData) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(homeStaticDataProvider);
                ref.invalidate(homeCarouselProvider);
                await ref.read(homeStaticDataProvider.future);
                await ref.read(homeCarouselProvider.future);
                await ref.read(homeRecommendCreditProductsProvider.notifier).refresh();
              },
              color: const Color(0xFF213775),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    final metrics = notification.metrics;
                    if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                      ref.read(homeRecommendCreditProductsProvider.notifier).loadMore();
                    }
                  }
                  return false;
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    // 顶部栏：Logo + 搜索框 + 消息
                    // const SliverToBoxAdapter(child: HomeAppBar()),

                    // Banner（轮播图，真实 API 数据）
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 2, bottom: 4),
                      sliver: SliverToBoxAdapter(
                        child: carouselAsync.when(
                          data: (banners) => home_widgets.HomeBanner(banners: banners),
                          loading: () => const SizedBox(height: 220),
                          error: (_, _) => const SizedBox(height: 220),
                        ),
                      ),
                    ),

                    // White Card 1: 新人礼 + 可用商品
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      sliver: SliverToBoxAdapter(
                        child: HomePromoSection(gifts: staticData.newUserGifts, products: staticData.hotProducts),
                      ),
                    ),

                    // White Card 2: 金刚区 (10项 2x5 网格)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      sliver: SliverToBoxAdapter(child: HomeKingKongGrid(items: staticData.kingKongItems)),
                    ),

                    // White Card 3: 每月权益
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      sliver: SliverToBoxAdapter(child: HomeMonthlyBenefits(benefits: staticData.monthlyBenefits)),
                    ),

                    // White Card 4: 热卖商品
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      sliver: SliverToBoxAdapter(child: HomeHotProducts()),
                    ),

                    // White Card 5: 线上活动 (2大图并排)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      sliver: SliverToBoxAdapter(child: HomeActivitySection(blocks: staticData.activityBlocks)),
                    ),

                    // White Card 6: 线下活动 (3图并排)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      sliver: SliverToBoxAdapter(child: HomeTopicActivitySection(blocks: staticData.topicActivityBlocks)),
                    ),

                    // 底部商品展示区 (推荐青稞粒商品列表，支持滚动加载)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      sliver: SliverToBoxAdapter(child: HomeBottomRecommendSection()),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 15)),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(right: AppSpacing.lg, bottom: 20, child: PointsFloatingButtons()),
        ],
      ),
    );
  }
}
