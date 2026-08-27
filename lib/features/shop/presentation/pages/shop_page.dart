import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/shop_paging_providers.dart';
import '../widgets/shop_product_card.dart';
import '../widgets/shop_search_bar.dart';

class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      setState(() => _searching = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _searching = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(shopCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('特色商城'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            height: kToolbarHeight,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('全部')),
                  DropdownMenuItem(value: 'featured', child: Text('特色推荐')),
                  DropdownMenuItem(value: 'self', child: Text('天佑德自营')),
                  DropdownMenuItem(value: 'region', child: Text('青藏特产')),
                  DropdownMenuItem(value: 'drink', child: Text('水果饮料')),
                  DropdownMenuItem(value: 'gift', child: Text('礼盒装')),
                  DropdownMenuItem(value: 'hot', child: Text('热卖商品')),
                ],
                onChanged: (value) {
                  setState(() => _selectedCategory = value ?? 'all');
                },
              ),
            ),
          ),
        ),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stackTrace) => Center(
          child: AppError(message: '加载失败: $error', onRetry: () => ref.invalidate(shopCategoriesProvider)),
        ),
        data: (categories) => Consumer(
          builder: (context, ref, _) {
            final selectedCategory = _selectedCategory;
            final productsData = ref.watch(shopProductListProvider(selectedCategory));

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ShopSearchBar(controller: _searchController, onSearch: _onSearch),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedCategory != 'all') ...[
                          Text(_getTitleForCategory(selectedCategory), style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                    ),
                  ),
                ),
                if (productsData.status == PagingStatus.loading && productsData.items.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (productsData.status == PagingStatus.error && productsData.items.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(child: Text('加载失败: ${productsData.errorMessage}')),
                  )
                else if (productsData.items.isEmpty)
                  const SliverToBoxAdapter(child: AppEmpty(message: '暂无商品'))
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == productsData.items.length) {
                            return _buildFooter(ref, productsData, selectedCategory);
                          }
                          return ShopProductCard(product: productsData.items[index]);
                        },
                        childCount: productsData.items.length + (productsData.hasMore ? 1 : 0),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(WidgetRef ref, PagingData pagingData, String categoryId) {
    if (pagingData.status == PagingStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (pagingData.hasMore) {
      return Center(
        child: TextButton(
          onPressed: () => ref.read(shopProductListProvider(categoryId).notifier).loadMore(),
          child: const Text('加载更多'),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _getTitleForCategory(String categoryId) {
    switch (categoryId) {
      case 'featured':
        return '特色推荐';
      case 'self':
        return '天佑德自营';
      case 'region':
        return '青藏特产';
      case 'drink':
        return '水果饮料';
      case 'gift':
        return '礼盒装';
      case 'hot':
        return '热卖商品';
      default:
        return '全部';
    }
  }
}
