import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/route_names.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../../core/widgets/app_error.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../providers/points_mall_paging_providers.dart';
import '../providers/credit_product_list_provider.dart';
import '../providers/credit_product_category_provider.dart';
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

final pointsMallProfilePointsProvider = FutureProvider<({int points, int expiringPoints})>((ref) async {
  final response = await ref.read(authProvider.notifier).getCurrentUser();
  if (!response.success || response.data == null) {
    throw Exception(response.message);
  }
  return (points: response.data!.points, expiringPoints: response.data!.expiringPoints);
});

class _PointsMallPageState extends ConsumerState<PointsMallPage> {
  final _searchController = TextEditingController();
  int _activeCategoryId = 0;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => ref.read(pointsMallProfilePointsProvider));
  }

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
      backgroundColor: const Color(0xFF213775),
      body: staticDataAsync.when(
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
          // 个人资料接口返回的 paycredit 覆盖积分商城首页模型中的积分 Mock 值
          // 其余积分商城数据仍由积分商城接口提供。

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
                              child: SizedBox(
                                height: 260,
                                child: PointsBanner(
                                  imageUrl: staticData.bannerUrls.first,
                                  imageUrls: staticData.bannerUrls.length > 1 ? staticData.bannerUrls : null,
                                  height: 260,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 3),
                                ),
                              ),
                            ),

                            // ==================== 积分卡片（动态高度自然流布局，避免写死总高度导致空白） ====================
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 207 + statusBarHeight),
                                  PointsBalanceCard(
                                    currentPoints: ref
                                        .watch(pointsMallProfilePointsProvider)
                                        .maybeWhen(data: (profile) => profile.points, orElse: () => staticData.currentPoints),
                                    expiringPoints: ref
                                        .watch(pointsMallProfilePointsProvider)
                                        .maybeWhen(data: (profile) => profile.expiringPoints, orElse: () => staticData.expiringPoints),
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
                      tabHeight: 54,
                      margin: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, top: 5),
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
                    padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md),
                    sliver: SliverToBoxAdapter(
                      child: CreditProductListPanel(groups: staticData.redeemableGroups, activeCategoryId: _activeCategoryId),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                ],
              ),
            ),
            Positioned(right: AppSpacing.lg, bottom: 20, child: const PointsFloatingButtons()),
          ],
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
