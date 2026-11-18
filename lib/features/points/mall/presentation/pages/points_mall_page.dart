import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/route_names.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../providers/credit_product_list_provider.dart';
import '../providers/credit_product_category_provider.dart';
import '../providers/points_mall_providers.dart';
import '../widgets/points_banner.dart';
import '../widgets/points_balance_card.dart';
import '../widgets/points_category_tab_bar.dart';
import '../widgets/points_floating_buttons.dart';
import '../widgets/credit_product_list_panel.dart';

class PointsMallPage extends ConsumerStatefulWidget {
  const PointsMallPage({super.key});

  @override
  ConsumerState<PointsMallPage> createState() => _PointsMallPageState();
}

/// 积分商城顶部 Banner：静态设计资源，不走接口
const _kPointsBannerAsset = 'assets/images/points/banner.jpg';

class _PointsMallPageState extends ConsumerState<PointsMallPage> {
  int _activeCategoryId = 0;

  void _onCategoryChanged(int categoryId) {
    setState(() => _activeCategoryId = categoryId);
    ref.read(creditProductListProvider.notifier).setCategoryId(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(pointsMallProfilePointsProvider);
    final productsAsync = ref.watch(creditProductCategoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF213775),
      body: Stack(
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
                  child: Builder(
                    builder: (context) {
                      final statusBarHeight = MediaQuery.of(context).padding.top;
                      return Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: statusBarHeight),
                            child: const SizedBox(height: 260, child: PointsBanner(imageUrl: _kPointsBannerAsset, height: 260, autoPlay: false)),
                          ),

                          // ==================== 积分卡片（动态高度自然流布局，避免写死总高度导致空白） ====================
                          Padding(
                            padding: AppSpacing.pageHorizontal,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 207 + statusBarHeight),
                                PointsBalanceCard(
                                  currentPoints: profileAsync.maybeWhen(data: (profile) => profile.points, orElse: () => 0),
                                  expiringPoints: profileAsync.maybeWhen(data: (profile) => profile.expiringPoints, orElse: () => 0),
                                  onDetailTap: () => GoRouter.of(context).push(RouteNames.pointsDetail),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: _CategoryTabBarDelegate(
                    tabHeight: 53,
                    margin: const EdgeInsets.only(left: AppSpacing.compactPageMargin, right: AppSpacing.compactPageMargin, top: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        productsAsync.when(
                          loading: () => const SizedBox(height: 44, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          error: (_, _) => const SizedBox(height: 44),
                          data: (catData) =>
                              PointsCategoryTabBar(categories: catData.categories, activeCategoryId: _activeCategoryId, onCategoryTap: _onCategoryChanged),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: AppSpacing.compactPageMargin, right: AppSpacing.compactPageMargin),
                  sliver: SliverToBoxAdapter(child: CreditProductListPanel(activeCategoryId: _activeCategoryId)),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              ],
            ),
          ),
          Positioned(right: AppSpacing.lg, bottom: 20, child: const PointsFloatingButtons()),
        ],
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
        child: Container(color: const Color(0xFF213775), child: child),
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
