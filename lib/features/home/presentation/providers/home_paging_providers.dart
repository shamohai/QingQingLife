import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/domain/repositories/product_repository.dart';
import '../../../points/mall/data/models/get_recommend_product_list_model.dart';
import '../../../points/mall/data/models/get_credit_product_list_model.dart';
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

final homeHotProductsProvider = NotifierProvider.autoDispose<HomeHotProductsNotifier, PagingData<CreditMallProduct>>(HomeHotProductsNotifier.new);

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
    return PagingResult<ProductCard>(items: result.products, hasMore: result.hasMore, totalItems: result.total, totalPages: (result.total / pageSize).ceil());
  }
}

final homeProductGridProvider = NotifierProvider.autoDispose<HomeProductGridNotifier, PagingData<ProductCard>>(HomeProductGridNotifier.new);

/// 首页底部推荐商品分页 Notifier（调用 GetCreditProductList 接口）
/// 接口：POST /api/product/getcreditproductlist，sort=1, asc=false
class HomeRecommendCreditProductsNotifier extends PagingNotifier<CreditProductItem> {
  @override
  int get pageSize => 10;

  @override
  Future<PagingResult<CreditProductItem>> fetchPage(int page, int pageSize) async {
    final repository = ref.read(pointsRepositoryProvider);
    final response = await repository.getCreditProductList(page: page, pageSize: pageSize, sort: 1, asc: false);
    if (!response.success || response.data == null) {
      throw Exception(response.message);
    }
    final data = response.data!;
    return PagingResult<CreditProductItem>(
      items: data.products,
      hasMore: data.hasMore,
      totalItems: data.total,
      totalPages: pageSize > 0 ? (data.total / pageSize).ceil() : 1,
    );
  }
}

final homeRecommendCreditProductsProvider = NotifierProvider.autoDispose<HomeRecommendCreditProductsNotifier, PagingData<CreditProductItem>>(
  HomeRecommendCreditProductsNotifier.new,
);
