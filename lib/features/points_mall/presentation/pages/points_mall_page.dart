import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/points_mall_paging_providers.dart';
import '../widgets/points_banner.dart';
import '../widgets/points_balance_card.dart';
import '../widgets/points_category_tab_bar.dart';
import '../widgets/points_floating_buttons.dart';
import '../widgets/points_search_area.dart';
import '../widgets/hot_products_section.dart';
import '../widgets/redeemable_section.dart';
import '../../data/models/points_mall_home_data.dart';

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

  void _onExchange(PointsProduct product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('兑换商品：${product.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staticDataAsync = ref.watch(pointsMallStaticDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pointsMallStaticDataProvider);
          ref.invalidate(pointsMallHotProductsProvider);
        },
        child: staticDataAsync.when(
          loading: () => const CustomScrollView(
            slivers: [SliverFillRemaining(child: Center(child: AppLoading()))],
          ),
          error: (error, stackTrace) => CustomScrollView(
            slivers: [SliverFillRemaining(child: Center(child: AppError(message: '加载失败: $error', onRetry: () => ref.invalidate(pointsMallStaticDataProvider))))],
          ),
          data: (staticData) => Stack(
            children: [
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: PointsSearchArea()),
                  const SliverToBoxAdapter(child: SizedBox(height: 2)),
                  SliverPersistentHeader(
                    pinned: true,
                    floating: true,
                    delegate: _CategoryTabBarDelegate(tabHeight: 56, child: PointsCategoryTabBar(categories: staticData.categories, activeCategoryId: _activeCategoryId, onCategoryTap: _onCategoryChanged)),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.md, left: AppSpacing.lg, right: AppSpacing.lg),
                      child: PointsBanner(imageUrl: staticData.bannerUrls.firstOrNull ?? staticData.bannerUrls.first),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                  SliverToBoxAdapter(child: PointsBalanceCard(currentPoints: staticData.currentPoints, expiringPoints: staticData.expiringPoints, expiryDate: staticData.expiryDate, onDetailTap: () {})),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                  const SliverToBoxAdapter(child: HotProductsSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                  SliverToBoxAdapter(child: RedeemableSection(groups: staticData.redeemableGroups, onExchange: _onExchange)),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
                ],
              ),
              Positioned(right: AppSpacing.lg, bottom: 100, child: const PointsFloatingButtons()),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTabBarDelegate extends SliverPersistentHeaderDelegate {
  final double tabHeight;
  final Widget child;

  const _CategoryTabBarDelegate({required this.tabHeight, required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: const Color(0xFFF3F5F7), child: child);

  @override
  double get maxExtent => tabHeight;

  @override
  double get minExtent => tabHeight;

  @override
  bool shouldRebuild(covariant _CategoryTabBarDelegate oldDelegate) => tabHeight != oldDelegate.tabHeight || child != oldDelegate.child;
}
