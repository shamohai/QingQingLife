import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/points_mall_paging_providers.dart';
import '../widgets/hot_products_section.dart';
import '../widgets/points_balance_card.dart';
import '../widgets/points_banner_carousel.dart';
import '../widgets/points_category_tab_bar.dart';
import '../widgets/points_search_app_bar.dart';
import '../widgets/redeemable_section.dart';

class PointsMallPage extends ConsumerStatefulWidget {
  const PointsMallPage({super.key});

  @override
  ConsumerState<PointsMallPage> createState() => _PointsMallPageState();
}

class _PointsMallPageState extends ConsumerState<PointsMallPage> {
  final _searchController = TextEditingController();
  String _activeCategoryId = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String categoryId) {
    setState(() => _activeCategoryId = categoryId);
    ref.read(pointsMallProductListProvider.notifier).setCategoryId(categoryId);
    ref.read(pointsMallProductListProvider.notifier).loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    final staticDataAsync = ref.watch(pointsMallStaticDataProvider);

    return Scaffold(
      appBar: PointsSearchAppBar(searchController: _searchController),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pointsMallStaticDataProvider);
          ref.invalidate(pointsMallHotProductsProvider);
        },
        child: staticDataAsync.when(
          loading: () => const CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Center(child: AppLoading()),
              ),
            ],
          ),
          error: (error, stackTrace) => CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Center(
                  child: AppError(
                    message: '加载失败: $error',
                    onRetry: () => ref.invalidate(pointsMallStaticDataProvider),
                  ),
                ),
              ),
            ],
          ),
          data: (staticData) => CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 轮播图
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: PointsBannerCarousel(imageUrls: staticData.bannerUrls),
                ),
              ),
              // 积分余额卡片
              SliverToBoxAdapter(
                child: PointsBalanceCard(
                  currentPoints: staticData.currentPoints,
                  expiringPoints: staticData.expiringPoints,
                  expiryDate: staticData.expiryDate,
                  onDetailTap: () {},
                ),
              ),
              // 热门兑换商品
              const SliverToBoxAdapter(child: HotProductsSection()),
              // 分类 Tab
              SliverToBoxAdapter(
                child: PointsCategoryTabBar(
                  categories: staticData.categories,
                  activeCategoryId: _activeCategoryId,
                  onCategoryTap: _onCategoryChanged,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              // 我能兑换
              SliverToBoxAdapter(
                child: RedeemableSection(groups: staticData.redeemableGroups),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
            ],
          ),
        ),
      ),
    );
  }
}
