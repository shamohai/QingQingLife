import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/providers/repository_providers.dart';

/// 商品数据（特色商城用）
class ShopProduct {
  final String id;
  final String imageUrl;
  final String name;
  final int priceCents;
  final int? originalPriceCents;
  final String? tag;
  final int? salesCount;

  const ShopProduct({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.priceCents,
    this.originalPriceCents,
    this.tag,
    this.salesCount,
  });
}

/// 分类数据
class ShopCategory {
  final String id;
  final String label;
  final IconData icon;

  const ShopCategory({required this.id, required this.label, required this.icon});
}

/// 特色商城数据聚合模型
class ShopData {
  final List<ShopCategory> categories;
  final List<ShopProduct> allProducts;
  final List<String> hotSearchKeywords;

  const ShopData({required this.categories, required this.allProducts, required this.hotSearchKeywords});

  List<ShopProduct> getProductsByCategory(String categoryId) {
    if (categoryId == 'all') return allProducts;
    return allProducts.where((p) {
      if (categoryId == 'featured') return p.salesCount != null && p.salesCount! > 500;
      if (categoryId == 'self') return p.tag == '自营';
      if (categoryId == 'region') return p.tag == '青藏特产';
      if (categoryId == 'hot') return p.salesCount != null && p.salesCount! > 1000;
      return true;
    }).toList();
  }
}

/// 特色商城数据异步 Provider - 通过 Repository 获取数据
final shopDataProvider = FutureProvider<ShopData>((ref) async {
  final repository = ref.read(productRepositoryProvider);

  final categoriesResponse = await repository.getCategories();
  if (!categoriesResponse.success || categoriesResponse.data == null) {
    throw Exception(categoriesResponse.message ?? '获取分类失败');
  }

  final productsResponse = await repository.getProductList(page: 1, pageSize: 100);
  if (!productsResponse.success || productsResponse.data == null) {
    throw Exception(productsResponse.message ?? '获取商品列表失败');
  }

  final categories = categoriesResponse.data!
      .map((c) => ShopCategory(id: c.id, label: c.label, icon: _getIconForCategory(c.id)))
      .toList();

  final products = productsResponse.data!.products
      .map(
        (p) => ShopProduct(
          id: p.id,
          imageUrl: p.imageUrl,
          name: p.name,
          priceCents: p.priceCents,
          originalPriceCents: p.originalPriceCents,
          tag: p.tag,
          salesCount: p.salesCount,
        ),
      )
      .toList();

  return ShopData(
    categories: categories,
    allProducts: products,
    hotSearchKeywords: const ['青稞酒', '牛肉干', '菜籽油', '枸杞', '礼盒', '红酒', '特惠'],
  );
});

IconData _getIconForCategory(String categoryId) {
  switch (categoryId) {
    case 'all':
      return Icons.apps_outlined;
    case 'featured':
      return Icons.star_border;
    case 'self':
      return Icons.verified;
    case 'region':
      return Icons.nature;
    case 'drink':
      return Icons.local_drink;
    case 'gift':
      return Icons.card_giftcard;
    case 'hot':
      return Icons.whatshot;
    default:
      return Icons.category_outlined;
  }
}
