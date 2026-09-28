import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../../../../core/widgets/app_empty.dart';
import '../../../../../core/widgets/app_error.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../providers/credit_product_list_provider.dart';
import '../widgets/all_product_card.dart';
import '../widgets/all_products_search_bar.dart';
import '../widgets/responsive_product_grid_delegate.dart';
import '../../data/models/get_credit_product_list_model.dart';
import '../../data/models/get_recommend_product_list_model.dart';

/// 全部商品页面
///
/// 入口：积分商城 → 热门兑换商品 → 查看全部
class AllProductsPage extends ConsumerStatefulWidget {
  const AllProductsPage({super.key});

  @override
  ConsumerState<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends ConsumerState<AllProductsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(creditProductListProvider.notifier).setCategoryId(0);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onProductTap(BuildContext context, CreditProductItem item) {
    final isService = item.productType == CreditProductType.serviceCouponIntegral || item.productType == CreditProductType.serviceCouponSale;
    if (isService) {
      GoRouter.of(context).push('/points/service/${item.productId}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('即将兑换：${item.productName}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagingData = ref.watch(creditProductListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ─── Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 12),
              child: Row(
                children: [
                  // 返回按钮
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back, size: 24, color: Color(0xFF1F2024)),
                  ),
                  const SizedBox(width: 4),
                  // 标题
                  const Text(
                    '全部商品',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
                  ),
                  const SizedBox(width: 12),
                  // 搜索栏自适应剩余空间
                  Expanded(child: AllProductsSearchBar(searchController: _searchController)),
                ],
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
                child: AppError(message: '加载失败', onRetry: () => ref.read(creditProductListProvider.notifier).loadFirstPage()),
              ),
            )
          else if (pagingData.status == PagingStatus.empty || (pagingData.status == PagingStatus.loaded && pagingData.items.isEmpty))
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: AppEmpty(message: '暂无商品')),
            )
          else
            SliverPadding(
              // 左右各14dp，顶部12dp（与header间距），底部覆盖 BottomNav
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 96),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= pagingData.items.length) {
                    if (pagingData.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    if (!pagingData.hasMore && pagingData.items.isNotEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text('没有更多数据了', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                  return AllProductCard(item: pagingData.items[index], onTap: () => _onProductTap(context, pagingData.items[index]));
                }, childCount: pagingData.items.length + 1),
                gridDelegate: const ResponsiveProductGridDelegate(crossAxisSpacing: 12, mainAxisSpacing: 12),
              ),
            ),
        ],
      ),
    );
  }
}
