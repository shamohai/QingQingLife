import 'package:flutter/material.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_spacing.dart';
import '../providers/shop_provider.dart';
import '../widgets/shop_category_tabs.dart';
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
      // 简单过滤：实际项目应调用 API
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _searching = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.read(shopDataProvider);
    final products = _searching
        ? data.allProducts.where((p) => p.name.contains(_searchController.text)).toList()
        : data.getProductsByCategory(_selectedCategory);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                ShopSearchBar(
                  controller: _searchController,
                  onSearch: _onSearch,
                ),
                ShopCategoryTabs(
                  selectedCategoryId: _selectedCategory,
                  onCategoryChanged: (id) => setState(() => _selectedCategory = id),
                ),
              ],
            ),
          ),
          if (_searching)
            SliverToBoxAdapter(child: AppLoading())
          else if (products.isEmpty)
            SliverToBoxAdapter(child: const AppEmpty(message: '暂无商品'))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ShopProductCard(product: products[index]),
                  childCount: products.length,
                ),
              ),
            ),
          SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}
