import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/points_mall_paging_providers.dart';
import '../providers/credit_product_list_provider.dart';
import '../providers/credit_product_category_provider.dart';
import '../widgets/points_banner.dart';
import '../widgets/points_balance_card.dart';
import '../widgets/points_category_tab_bar.dart';
import '../widgets/points_floating_buttons.dart';
import '../widgets/points_search_area.dart';
import '../widgets/credit_product_list_panel.dart';

class PointsMallPage extends ConsumerStatefulWidget {
  const PointsMallPage({super.key});

  @override
  ConsumerState<PointsMallPage> createState() => _PointsMallPageState();
}

class _PointsMallPageState extends ConsumerState<PointsMallPage> {
  final _searchController = TextEditingController();
  int _activeCategoryId = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(int categoryId) {
    setState(() => _activeCategoryId = categoryId);
    ref.read(creditProductListProvider.notifier).setCategoryId(categoryId);
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
                  child: AppError(message: '加载失败: $error', onRetry: () => ref.invalidate(pointsMallStaticDataProvider)),
                ),
              ),
            ],
          ),
          data: (staticData) => Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // 过滤只响应主纵向 CustomScrollView 的滚动，忽略 Banner PageView 等横向或嵌套 Scrollable 的 notification
                  if (notification.metrics.axis == Axis.vertical && notification.depth == 0) {
                    if (notification.metrics.extentAfter < 200) {
                      final pagingData = ref.read(creditProductListProvider);
                      if (pagingData.hasMore && !pagingData.isLoading && !pagingData.isError) {
                        ref.read(creditProductListProvider.notifier).loadMore();
                      }
                    }
                  }
                  return false;
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 260,
                            child: PointsBanner(
                              imageUrl: staticData.bannerUrls.first,
                              imageUrls: staticData.bannerUrls.length > 1 ? staticData.bannerUrls : null,
                              height: 260, // 传进去
                              autoPlay: true, // 默认就是 true，可省略
                              autoPlayInterval: const Duration(seconds: 3),
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                                child: PointsSearchArea(searchController: _searchController),
                              ),
                              const SizedBox(height: 142),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: PointsBalanceCard(
                                  currentPoints: staticData.currentPoints,
                                  expiringPoints: staticData.expiringPoints,
                                  expiryDate: staticData.expiryDate,
                                  onDetailTap: () => GoRouter.of(context).push(RouteNames.pointsDetail),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      floating: true,
                      delegate: _CategoryTabBarDelegate(
                        tabHeight: 44 + 10,
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ref
                                .watch(creditProductCategoryProvider)
                                .when(
                                  loading: () => const SizedBox(height: 44, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                                  error: (_, __) => const SizedBox(height: 44),
                                  data: (catData) => PointsCategoryTabBar(
                                    categories: catData.categories,
                                    activeCategoryId: _activeCategoryId,
                                    onCategoryTap: _onCategoryChanged,
                                  ),
                                ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      sliver: SliverToBoxAdapter(
                        child: CreditProductListPanel(groups: staticData.redeemableGroups, activeCategoryId: _activeCategoryId),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                  ],
                ),
              ),
              Positioned(right: AppSpacing.lg, bottom: 50, child: const PointsFloatingButtons()),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTabBarDelegate extends SliverPersistentHeaderDelegate {
  final double tabHeight;
  final EdgeInsets margin;
  final Widget child;

  const _CategoryTabBarDelegate({required this.tabHeight, this.margin = EdgeInsets.zero, required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        child: Container(color: const Color(0xFFF3F5F7), child: child),
      ),
    );
  }

  @override
  double get maxExtent => tabHeight;

  @override
  double get minExtent => tabHeight;

  @override
  bool shouldRebuild(covariant _CategoryTabBarDelegate oldDelegate) {
    return tabHeight != oldDelegate.tabHeight || margin != oldDelegate.margin || child != oldDelegate.child;
  }
}
