import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../../../core/presentation/paging/paging_list_view.dart';
import '../../../../core/providers/repository_providers.dart';
import 'shop_provider.dart';

/// 特色商城商品分页 Notifier
class ShopProductListNotifier extends PagingNotifier<ShopProduct> {
  final String categoryId;
  ShopProductListNotifier(this.categoryId);

  @override
  int get pageSize => 10;

  @override
  Future<PagingResult<ShopProduct>> fetchPage(int page, int pageSize) async {
    final repository = ref.read(productRepositoryProvider);
    final response = await repository.getProductList(
      page: page,
      pageSize: pageSize,
      categoryId: categoryId == 'all' ? null : categoryId,
    );
    if (!response.success || response.data == null) {
      throw Exception(response.message ?? '获取商品列表失败');
    }
    final result = response.data!;
    final products = result.products
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
    return PagingResult<ShopProduct>(
      items: products,
      hasMore: result.hasMore,
      totalItems: result.total,
      totalPages: (result.total / pageSize).ceil(),
    );
  }
}

final shopProductListProvider =
    NotifierProvider.autoDispose.family<ShopProductListNotifier, PagingData<ShopProduct>, String>(
  (arg) => ShopProductListNotifier(arg),
);

/// 特色商城分类 Provider
final shopCategoriesProvider = FutureProvider<List<ShopCategory>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final response = await repository.getCategories();
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? '获取分类失败');
  }
  return response.data!.map((c) => ShopCategory(id: c.id, label: c.label, icon: _getIconForCategory(c.id))).toList();
});

/// 根据分类 ID 返回对应的 IconData
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
