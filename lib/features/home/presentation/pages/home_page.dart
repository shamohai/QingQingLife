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
import '../widgets/home_new_user_gift_card.dart';
import '../widgets/home_available_products.dart';
import '../widgets/home_monthly_benefits.dart';
import '../widgets/home_hot_products.dart';
import '../widgets/home_activity_section.dart';
import '../widgets/home_topic_activity_section.dart';
import '../widgets/home_branding_footer.dart';
import '../widgets/home_product_grid.dart';

/// 首页静态数据 Provider
/// 
/// 负责一次性拉取首页所需的聚合数据（轮播图、金刚区图标、促销配置等）。
/// 采用 FutureProvider 确保数据加载完成后再构建 UI。
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

/// 首页静态聚合数据模型
/// 
/// 封装了首页多个业务板块的数据结构。
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

/// 首页主页面
/// 
/// 采用 CustomScrollView 配合多个 Sliver 组件实现高性能的长列表滚动。
/// 页面结构包含：搜索栏、轮播、金刚区、新人礼包、专题活动、权益板块、热销商品列表等。
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
            // 自定义顶部搜索栏
            SliverToBoxAdapter(child: const HomeAppBar()),
            
            // 轮播图区域
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: home_widgets.HomeBanner(imageUrls: staticData.banners.map((b) => b.imageUrl).toList()),
              ),
            ),
            
            // 新人专享礼包卡片
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: HomeNewUserGiftCard(gifts: staticData.newUserGifts),
              ),
            ),
            
            // 可用商品/热力推荐区域
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: HomeAvailableProducts(products: staticData.hotProducts),
              ),
            ),
            
            // 金刚区（九宫格入口）
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: HomeKingKongGrid(items: staticData.kingKongItems),
              ),
            ),
            
            // 每月权益板块
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: HomeMonthlyBenefits(benefits: staticData.monthlyBenefits),
              ),
            ),
            
            // 爆款商品（异步加载）
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: const HomeHotProducts(),
              ),
            ),
            
            // 活动运营位区域
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: HomeActivitySection(blocks: staticData.activityBlocks),
              ),
            ),
            
            // 专题运营位区域
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: HomeTopicActivitySection(blocks: staticData.topicActivityBlocks),
              ),
            ),
            
            // 品牌页脚（Slogan）
            const SliverToBoxAdapter(
              child: HomeBrandingFooter(),
            ),
            
            // 首页商品瀑布流/网格
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: const HomeProductGrid(),
              ),
            ),
            
            // 底部占位，避免被 TabBar 遮挡
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }
}
