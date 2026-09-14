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
import '../widgets/two_panel_product_section.dart';
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
            slivers: [
              SliverFillRemaining(
                child: Center(
                  child: AppError(
                    message: '加载失败: $error',
                    onRetry: () => ref.invalidate(pointsMallStaticDataProvider),
                  ),
                ),
              )
            ],
          ),
          data: (staticData) => Stack(
            children: [
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── 顶部沉浸式区域：Banner + 搜索浮层 ──
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 450,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PointsBanner(
                            imageUrl: staticData.bannerUrls.first,
                            imageUrls: staticData.bannerUrls.length > 1
                                ? staticData.bannerUrls
                                : null,
                          ),
                          Positioned(
                            top: 12,
                            left: 16,
                            right: 16,
                            child: PointsSearchArea(searchController: _searchController),
                          ),
                          // 余额卡覆盖 Banner 底部
                          Positioned(
                            bottom: -70,
                            left: 16,
                            right: 16,
                            child: PointsBalanceCard(
                              currentPoints: staticData.currentPoints,
                              expiringPoints: staticData.expiringPoints,
                              expiryDate: staticData.expiryDate,
                              onDetailTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── 商品分类 Tab 栏（sticky 钉住） ──
                  SliverPersistentHeader(
                    pinned: true,
                    floating: true,
                    delegate: _CategoryTabBarDelegate(
                      tabHeight: 37, // 修正为设计稿高度 37
                      child: PointsCategoryTabBar(
                        categories: staticData.categories.map((c) => c.label).toList(),
                        activeCategoryId: _activeCategoryId,
                        onCategoryTap: _onCategoryChanged,
                      ),
                    ),
                  ),
                  // ── 双栏商品列表 ──
                  SliverToBoxAdapter(
                    child: TwoPanelProductSection(
                      groups: staticData.redeemableGroups,
                      onExchange: _onExchange,
                    ),
                  ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: const Color(0xFFF3F5F7), child: child);

  @override
  double get maxExtent => tabHeight;

  @override
  double get minExtent => tabHeight;

  @override
  bool shouldRebuild(covariant _CategoryTabBarDelegate oldDelegate) =>
      tabHeight != oldDelegate.tabHeight || child != oldDelegate.child;
}
