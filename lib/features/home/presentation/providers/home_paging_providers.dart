import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../../../core/presentation/paging/paging_list_view.dart';
import '../../../../core/providers/repository_providers.dart';

/// 首页热卖商品分页 Notifier
class HomeHotProductsNotifier extends PagingNotifier<ProductCard> {
  @override
  int get pageSize => 10;

  @override
  Future<PagingResult<ProductCard>> fetchPage(int page, int pageSize) async {
    final repository = ref.read(productRepositoryProvider);
    final response = await repository.getProductList(page: page, pageSize: pageSize, categoryId: 'hot');
    if (!response.success || response.data == null) {
      throw Exception(response.message ?? '获取热卖商品失败');
    }
    final result = response.data!;
    return PagingResult<ProductCard>(
      items: result.products,
      hasMore: result.hasMore,
      totalItems: result.total,
      totalPages: (result.total / pageSize).ceil(),
    );
  }
}

final homeHotProductsProvider = NotifierProvider.autoDispose<HomeHotProductsNotifier, PagingData<ProductCard>>(
  HomeHotProductsNotifier.new,
);

/// 首页商品网格分页 Notifier
class HomeProductGridNotifier extends PagingNotifier<ProductCard> {
  @override
  int get pageSize => 8;

  @override
  Future<PagingResult<ProductCard>> fetchPage(int page, int pageSize) async {
    final repository = ref.read(productRepositoryProvider);
    final response = await repository.getProductList(page: page, pageSize: pageSize);
    if (!response.success || response.data == null) {
      throw Exception(response.message ?? '获取商品列表失败');
    }
    final result = response.data!;
    return PagingResult<ProductCard>(
      items: result.products,
      hasMore: result.hasMore,
      totalItems: result.total,
      totalPages: (result.total / pageSize).ceil(),
    );
  }
}

final homeProductGridProvider = NotifierProvider.autoDispose<HomeProductGridNotifier, PagingData<ProductCard>>(
  HomeProductGridNotifier.new,
);
