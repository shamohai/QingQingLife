import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('兑换商品：${product.name}')));
  }

  /// 点击服务商品行 → 跳转服务商品详情页
  /// 接收 BuildContext 确保导航可用（不依赖闭包捕获的上下文）
  void _onServiceTap(PointsProduct product, BuildContext context) {
    debugPrint('[PointsMall] _onServiceTap → id=${product.id} type=${product.type} name=${product.name}');
    GoRouter.of(context).push(RouteNames.serviceProductDetail.replaceFirst(':id', product.id));
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
              CustomScrollView(
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
                          PointsCategoryTabBar(categories: staticData.categories, activeCategoryId: _activeCategoryId, onCategoryTap: _onCategoryChanged),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    sliver: SliverToBoxAdapter(
                      child: TwoPanelProductSection(
                        groups: staticData.redeemableGroups,
                        onExchange: _onExchange,
                        onServiceTap: (product) => _onServiceTap(product, context),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                ],
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

  const _CategoryTabBarDelegate({
    required this.tabHeight,
    this.margin = EdgeInsets.zero,
    required this.child,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        child: Container(
          color: const Color(0xFFF3F5F7),
          child: child,
        ),
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
