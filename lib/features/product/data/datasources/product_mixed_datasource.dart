/// 商品数据源。
///
/// 首页接口使用真实后端数据；尚未完成 API 对接的商品能力暂时保留 Mock，
/// 以避免影响其他尚未迁移的页面。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../home/data/models/carousel_model.dart';
import '../../../home/data/models/weimeng_activity_location.dart';
import 'product_mock_datasource.dart';
import 'product_remote_datasource.dart';

/// 混合数据源：首页模块使用真实 API，其余未对接能力暂保留 Mock
class ProductMixedDataSource implements ProductRepository {
  final ProductRemoteDataSource _remote;
  final MockProductDataSource _mock;

  ProductMixedDataSource({required ApiClient apiClient}) : _remote = ProductRemoteDataSource(apiClient: apiClient), _mock = MockProductDataSource();

  @override
  Future<ApiResponse<List<CarouselBanner>>> getCarouselList({required CarouselType type}) async {
    return _remote.getCarouselList(type: type);
  }

  /// 首页模块仅使用真实接口，不再降级到 Mock 数据。
  @override
  Future<ApiResponse<HomeProductData>> getHomeProductData() {
    return _remote.getHomeProductData();
  }

  @override
  Future<ApiResponse<WeimengActivityLocation>> getWeimengActivityLocation() {
    return _remote.getWeimengActivityLocation();
  }

  @override
  Future<ApiResponse<ProductDetail>> getProductDetail(String productId) => _mock.getProductDetail(productId);

  @override
  Future<ApiResponse<ProductListResult>> getProductList({required int page, required int pageSize, String? categoryId, String? keyword, String? sortBy}) =>
      _mock.getProductList(page: page, pageSize: pageSize, categoryId: categoryId, keyword: keyword, sortBy: sortBy);

  @override
  Future<ApiResponse<List<ProductCategory>>> getCategories() => _mock.getCategories();

  @override
  Future<ApiResponse<ProductListResult>> searchProducts({required String keyword, required int page, required int pageSize}) =>
      _mock.searchProducts(keyword: keyword, page: page, pageSize: pageSize);
}

final productMixedDataSourceProvider = Provider<ProductMixedDataSource>((ref) {
  return ProductMixedDataSource(apiClient: ref.read(apiClientProvider));
});
