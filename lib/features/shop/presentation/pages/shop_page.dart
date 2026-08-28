import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';

import '../providers/shop_paging_providers.dart';
import '../widgets/shop_product_card.dart';
import '../widgets/shop_search_bar.dart';

class ShopPage extends ConsumerStatefulWidget {
  final String? initialKeyword;

  const ShopPage({super.key, this.initialKeyword});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {
  late final TextEditingController _searchController;
  String _selectedCategory = 'all';
  bool _searching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialKeyword ?? '');
    if (widget.initialKeyword != null && widget.initialKeyword!.isNotEmpty) {
      _hasSearched = true;
      _performSearch(widget.initialKeyword!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String keyword) {
    _searchController.text = keyword;
    setState(() => _searching = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _searching = false);
    });
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
          child: AppError(message: '加载失败: ', onRetry: () => ref.invalidate(shopCategoriesProvider)),
        ),
        data: (categories) => Consumer(
          builder: (context, ref, _) {
            final selectedCategory = _selectedCategory;
            final productsData = ref.watch(shopProductListProvider(selectedCategory));
            final searchKeyword = _searchController.text.trim();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ShopSearchBar(
                    controller: _searchController,
                    onSearch: _onSearch,
                  ),
                ),
                if (_hasSearched && _searching)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: AppSpacing.md),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  )
                else if (_hasSearched && searchKeyword.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 16, color: AppColors.outline),
                          const SizedBox(width: 4),
                          Text(
                            '搜索 "" 的结果',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedCategory != 'all' && !_hasSearched) ...[
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
                    child: Center(child: Text('加载失败: ')),
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