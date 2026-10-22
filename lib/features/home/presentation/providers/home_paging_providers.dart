import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/domain/repositories/product_repository.dart';
import '../../../points_mall/data/models/get_recommend_product_list_model.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../../../core/presentation/paging/paging_list_view.dart';
import '../../../../core/providers/repository_providers.dart';

/// 首页热卖商品分页 Notifier
/// 接口：POST /api/product/getrecommendproductlist，positioncode=APP_HOME
class HomeHotProductsNotifier extends PagingNotifier<CreditMallProduct> {
  @override
  int get pageSize => 10;

  @override
  Future<PagingResult<CreditMallProduct>> fetchPage(int page, int pageSize) async {
    final repository = ref.read(pointsRepositoryProvider);
    final response = await repository.getRecommendProductList(positionCode: 'APP_HOME');
    if (!response.success || response.data == null) {
      throw Exception(response.message);
    }
    final items = response.data!;
    return PagingResult<CreditMallProduct>(
      items: items,
      hasMore: false, // 推荐位接口为一次性返回，无分页
      totalItems: items.length,
      totalPages: 1,
    );
  }
}

final homeHotProductsProvider = NotifierProvider.autoDispose<HomeHotProductsNotifier, PagingData<CreditMallProduct>>(
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
      throw Exception(response.message);
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
