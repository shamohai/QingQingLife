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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('兑换商品：${product.name}')));
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
                  // ── 顶部组合区域（Banner背景 + 覆盖其上的积分信息流）──
                  // 采用 Stack 布局：底层为 Banner 图片，顶层为带位移的 Column，确保 z-index 正确且高度自适应
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        // [底层] Banner 视觉层
                        SizedBox(
                          height: 260, // 设定 Banner 的视觉背景高度
                          child: PointsBanner(
                            imageUrl: staticData.bannerUrls.first,
                            imageUrls: staticData.bannerUrls.length > 1 ? staticData.bannerUrls : null,
                          ),
                        ),
                        // [顶层] 内容层：包含搜索框占位 + 积分卡片
                        Column(
                          children: [
                            // 搜索框区域占位
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                              child: PointsSearchArea(searchController: _searchController),
                            ),
                            const SizedBox(height: 142), // 撑开高度，使下方卡片正好压在 Banner 边缘
                            // 积分余额卡片（此时天然处于 Banner 之上，类似 z-index: 1）
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: PointsBalanceCard(
                                currentPoints: staticData.currentPoints,
                                expiringPoints: staticData.expiringPoints,
                                expiryDate: staticData.expiryDate,
                                onDetailTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ── 商品分类 Tab 栏（sticky 钉住）──
                  SliverPersistentHeader(
                    pinned: true,
                    floating: true,
                    delegate: _CategoryTabBarDelegate(
                      tabHeight: 44 + 10, // 把间距算进高度
                      margin: const EdgeInsets.only(left: 10, right: 10), // 分类上方间距
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PointsCategoryTabBar(categories: staticData.categories, activeCategoryId: _activeCategoryId, onCategoryTap: _onCategoryChanged),
                          const SizedBox(height: 10), // 分类下方间距
                        ],
                      ),
                    ),
                  ),

                  // ── 双栏商品列表 ──
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    sliver: SliverToBoxAdapter(
                      child: TwoPanelProductSection(groups: staticData.redeemableGroups, onExchange: _onExchange),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
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
  final EdgeInsets margin;
  final Widget child;

  const _CategoryTabBarDelegate({
    required this.tabHeight,
    this.margin = EdgeInsets.zero, // 默认无边距
    required this.child,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      margin: margin, // 左右边距
      child: ClipRRect(
        // 左上 + 右上圆角
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        child: Container(
          color: const Color(0xFFF3F5F7), // 保持你原来的背景色
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
