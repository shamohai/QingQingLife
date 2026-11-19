import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../../../../core/widgets/app_empty.dart';
import '../../../../../core/widgets/app_error.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../providers/credit_product_list_provider.dart';
import '../../../../../app/router/route_names.dart';
import '../widgets/all_product_card.dart';
import '../widgets/all_products_search_bar.dart';
import '../widgets/responsive_product_grid_delegate.dart';
import '../../data/models/get_credit_product_list_model.dart';

/// 全部商品页面
///
/// 入口：积分商城 → 热门兑换商品 → 查看全部
class AllProductsPage extends ConsumerStatefulWidget {
  final int categoryId;

  const AllProductsPage({super.key, this.categoryId = 0});

  @override
  ConsumerState<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends ConsumerState<AllProductsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allCreditProductListProvider.notifier).clearPointsFilter(categoryId: widget.categoryId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onProductTap(BuildContext context, CreditProductItem item) {
    final route = item.isService ? RouteNames.serviceProductDetail : RouteNames.productDetail;
    GoRouter.of(context).push(route.replaceFirst(':id', item.productId.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final pagingData = ref.watch(allCreditProductListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(allCreditProductListProvider.notifier).refresh();
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < 200) {
              if (pagingData.hasMore && !pagingData.isLoading && !pagingData.isError) {
                ref.read(allCreditProductListProvider.notifier).loadMore();
              }
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ─── Header ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0, right: AppSpacing.md, top: 4, bottom: 4),
                    child: Row(
                      children: [
                        // 返回按钮
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 22),
                          onPressed: () => context.pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                        ),
                        //const SizedBox(width: 4),
                        // 标题
                        const Text(
                          '全部商品',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
                        ),
                        const SizedBox(width: 12),
                        // 搜索栏自适应剩余空间
                        Expanded(
                          child: AllProductsSearchBar(
                            searchController: _searchController,
                            onSearch: (keyword) {
                              FocusScope.of(context).unfocus();
                              ref.read(allCreditProductListProvider.notifier).setKeyword(keyword);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── 商品网格 ────────────────────────────────────────────
              if (pagingData.status == PagingStatus.loading && pagingData.items.isEmpty)
                const SliverFillRemaining(hasScrollBody: false, child: Center(child: AppLoading()))
              else if (pagingData.status == PagingStatus.error && pagingData.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: AppError(message: '加载失败', onRetry: () => ref.read(allCreditProductListProvider.notifier).refresh()),
                  ),
                )
              else if (pagingData.status == PagingStatus.empty || (pagingData.status == PagingStatus.loaded && pagingData.items.isEmpty))
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: AppEmpty(message: '暂无商品')),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.compactPageMargin, 8, AppSpacing.compactPageMargin, AppSpacing.md),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => AllProductCard(item: pagingData.items[index], onTap: () => _onProductTap(context, pagingData.items[index])),
                      childCount: pagingData.items.length,
                    ),
                    gridDelegate: const ResponsiveProductGridDelegate(crossAxisSpacing: AppSpacing.compactItemGap, mainAxisSpacing: 12),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.compactPageMargin,
                      8,
                      AppSpacing.compactPageMargin,
                      AppSpacing.md + MediaQuery.viewPaddingOf(context).bottom,
                    ),
                    child: _buildFooter(context, ref, pagingData),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, PagingData<CreditProductItem> pagingData) {
    if (pagingData.isLoading && pagingData.items.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (pagingData.status == PagingStatus.error && pagingData.items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: InkWell(
            onTap: () => ref.read(allCreditProductListProvider.notifier).loadMore(),
            child: const Text('加载失败，点击重试', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ),
      );
    }
    if (!pagingData.hasMore && pagingData.items.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: Text('没有更多数据了', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
