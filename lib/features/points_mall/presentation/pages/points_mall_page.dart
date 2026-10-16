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
              // child: CustomScrollView(
              //   physics: const AlwaysScrollableScrollPhysics(),
              //   slivers: [
              //     // ==================== 1. 顶部复合区域（Banner + 搜索 + 蒙层 + 积分卡片都在同一个 Stack 中） ====================
              //     SliverToBoxAdapter(
              //       child: SizedBox(
              //         // 总高度 = Banner高度(340) + 积分卡片向下延伸的部分（可根据你的卡片高度微调，例如总共给到 420 左右）
              //         height: 620,
              //         child: Stack(
              //           children: [
              //             // ① 底层：轮播 Banner
              //             Positioned.fill(
              //               child: PointsBanner(
              //                 imageUrl: staticData.bannerUrls.first,
              //                 imageUrls: staticData.bannerUrls.length > 1 ? staticData.bannerUrls : null,
              //                 height: 340,
              //                 autoPlay: true,
              //               ),
              //             ),

              //             // ② 搜索框
              //             Positioned(
              //               top: MediaQuery.of(context).padding.top + 8,
              //               left: 14,
              //               right: 14,
              //               child: PointsSearchArea(searchController: _searchController),
              //             ),

              //             // ③ 渐变蒙层（位于 Banner 和积分卡片之间，或者作为背景过渡）
              //             Positioned(
              //               top: 194,
              //               left: 0,
              //               right: 0,
              //               height: 165,
              //               child: IgnorePointer(
              //                 child: Container(
              //                   decoration: const BoxDecoration(
              //                     gradient: LinearGradient(
              //                       begin: Alignment.topCenter,
              //                       end: Alignment.bottomCenter,
              //                       colors: [Color(0x00D9D9D9), Color(0xFFF3F5F7)],
              //                       stops: [0.0, 0.72],
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),

              //             // ④ 最上层：积分卡片（绝对定位在设计稿的指定位置，确保在蒙层上方）
              //             Positioned(
              //               top: 306 - 49, // 或直接写你原本计算好的相对顶部距离（如 257）
              //               left: 14,
              //               right: 14,
              //               child: PointsBalanceCard(
              //                 currentPoints: staticData.currentPoints,
              //                 expiringPoints: staticData.expiringPoints,
              //                 expiryDate: staticData.expiryDate,
              //                 onDetailTap: () => GoRouter.of(context).push(RouteNames.pointsDetail),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),

              //     // ==================== 2. 分类 Tab ====================
              //     SliverPersistentHeader(
              //       pinned: true,
              //       floating: true,
              //       delegate: _CategoryTabBarDelegate(
              //         tabHeight: 54,
              //         margin: const EdgeInsets.only(left: 10, right: 10),
              //         child: Column(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             ref
              //                 .watch(creditProductCategoryProvider)
              //                 .when(
              //                   loading: () => const SizedBox(height: 44, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
              //                   error: (_, __) => const SizedBox(height: 44),
              //                   data: (catData) => PointsCategoryTabBar(
              //                     categories: catData.categories,
              //                     activeCategoryId: _activeCategoryId,
              //                     onCategoryTap: _onCategoryChanged,
              //                   ),
              //                 ),
              //             const SizedBox(height: 10),
              //           ],
              //         ),
              //       ),
              //     ),

              //     // ==================== 3. 商品列表 ====================
              //     SliverPadding(
              //       padding: const EdgeInsets.only(left: 10, right: 10),
              //       sliver: SliverToBoxAdapter(
              //         child: CreditProductListPanel(groups: staticData.redeemableGroups, activeCategoryId: _activeCategoryId),
              //       ),
              //     ),

              //     const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              //   ],
              // ),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  //第一种写法
                  // SliverToBoxAdapter(
                  //   child: SizedBox(
                  //     // 总高度 = 积分卡片顶部位置 + 积分卡片自身高度的一部分
                  //     // 这里用 306 - 状态栏近似 + 卡片高度，实际可微调
                  //     height: 306 - MediaQuery.of(context).padding.top + 392,
                  //     child: Stack(
                  //       clipBehavior: Clip.none,
                  //       children: [
                  //         // ========== 1. Banner 区域（对应 box_6，高度 340）==========
                  //         Positioned(
                  //           top: 0,
                  //           left: 0,
                  //           right: 0,
                  //           height: 340,
                  //           child: Stack(
                  //             children: [
                  //               // 轮播图
                  //               PointsBanner(
                  //                 imageUrl: staticData.bannerUrls.first,
                  //                 imageUrls: staticData.bannerUrls.length > 1 ? staticData.bannerUrls : null,
                  //                 height: 340,
                  //                 autoPlay: true,
                  //                 autoPlayInterval: const Duration(seconds: 3),
                  //               ),

                  //               // 搜索框（对应 section_3，margin-top: 19）
                  //               Positioned(
                  //                 top: MediaQuery.of(context).padding.top + 2,
                  //                 left: 14,
                  //                 right: 14,
                  //                 child: PointsSearchArea(
                  //                   searchController: _searchController,
                  //                   onSearch: () {
                  //                     FocusScope.of(context).unfocus();
                  //                   },
                  //                 ),
                  //               ),

                  //               // 渐变蒙层（对应 section_4，top: 194）
                  //               Positioned(
                  //                 left: 0,
                  //                 right: 0,
                  //                 top: 194,
                  //                 height: 165,
                  //                 child: IgnorePointer(
                  //                   child: Container(
                  //                     decoration: const BoxDecoration(
                  //                       gradient: LinearGradient(
                  //                         begin: Alignment.topCenter,
                  //                         end: Alignment.bottomCenter,
                  //                         colors: [
                  //                           Color(0x00D9D9D9), // 透明
                  //                           Color(0xFFF3F5F7), // 页面背景色
                  //                         ],
                  //                         stops: [0.0, 0.716],
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),

                  //               // 指示器 / 锚点（对应 group_4，在蒙层内 top: 48）
                  //               Positioned(
                  //                 top: 194 + 48, // 242
                  //                 left: 0,
                  //                 right: 0,
                  //                 child: Center(
                  //                   child: Container(
                  //                     width: 170,
                  //                     height: 3,
                  //                     color: Colors.white,
                  //                     alignment: Alignment.centerLeft,
                  //                     child: Container(width: 34, height: 3, color: const Color(0xFF0088FF)),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),

                  //         // ========== 2. 积分卡片（对应 box_7，top: 306）==========
                  //         Positioned(
                  //           top: 306 - 49, // 设计稿 top:306，Banner 从 49 开始，相对偏移约 257
                  //           // 更简单的写法：直接用 257（306-49）
                  //           left: 14,
                  //           right: 14,
                  //           child: PointsBalanceCard(
                  //             currentPoints: staticData.currentPoints,
                  //             expiringPoints: staticData.expiringPoints,
                  //             expiryDate: staticData.expiryDate,
                  //             onDetailTap: () => GoRouter.of(context).push(RouteNames.pointsDetail),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  //第2种写法
                  SliverToBoxAdapter(
                    child: SizedBox(
                      // Banner 340 + 积分卡片向上覆盖后探出的高度（约 100~120）
                      height: 436 + 110,
                      child: Stack(
                        clipBehavior: Clip.none,
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

                          // ==================== 4. 积分卡片（设计稿 top:306，相对 Banner 顶部约 257）====================
                          Positioned(
                            top: 207, // 306 - 49 ≈ 257（设计稿关键偏移）
                            left: 10,
                            right: 10,
                            child: PointsBalanceCard(
                              currentPoints: staticData.currentPoints,
                              expiringPoints: staticData.expiringPoints,
                              expiryDate: staticData.expiryDate,
                              onDetailTap: () => GoRouter.of(context).push(RouteNames.pointsDetail),
                            ),
                          ),

                          // ==================== 2. 搜索框 ====================
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 2,
                            left: 14,
                            right: 14,
                            child: PointsSearchArea(
                              searchController: _searchController,
                              onSearch: () {
                                FocusScope.of(context).unfocus();
                                // 搜索逻辑
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverPersistentHeader(
                    pinned: true,
                    floating: true,
                    delegate: _CategoryTabBarDelegate(
                      tabHeight: 54,
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
