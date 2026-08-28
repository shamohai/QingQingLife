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
      body: staticDataAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stackTrace) => Center(
          child: AppError(message: '加载失败: $error', onRetry: () => ref.invalidate(pointsMallStaticDataProvider)),
        ),
        data: (staticData) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(pointsMallStaticDataProvider),
          child: CustomScrollView(
            slivers: [
              // 轮播图
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
              // 分类 Tab + 我能兑换
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PointsCategoryTabBar(
                      categories: staticData.categories,
                      activeCategoryId: _activeCategoryId,
                      onCategoryTap: _onCategoryChanged,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    RedeemableSection(groups: staticData.redeemableGroups),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
