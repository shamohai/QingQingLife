/// 商品混合数据源
///
/// 已完成对接的接口走远程，尚未实现的后端接口继续走 Mock 占位。
///
/// 当前切换策略：
/// - getCarouselList     → ProductRemoteDataSource（已上线）
/// - 其余所有方法        → MockProductDataSource
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../home/data/models/carousel_model.dart';
import 'product_mock_datasource.dart';
import 'product_remote_datasource.dart';

/// 混合数据源：轮播图用真实 API，其余用 Mock 占位
class ProductMixedDataSource implements ProductRepository {
  final ProductRemoteDataSource _remote;
  final MockProductDataSource _mock;

  ProductMixedDataSource({required ApiClient apiClient})
      : _remote = ProductRemoteDataSource(apiClient: apiClient),
        _mock = MockProductDataSource();

  @override
  Future<ApiResponse<List<CarouselBanner>>> getCarouselList({required CarouselType type}) async {
    return _remote.getCarouselList(type: type);
  }

  /// 首页 4 个模块接口（金刚区、每月权益、线上活动、线下活动）切换为 Remote 接口
  @override
  Future<ApiResponse<HomeProductData>> getHomeProductData() async {
    try {
      final remoteRes = await _remote.getHomeProductData();
      if (remoteRes.success && remoteRes.data != null) {
        return remoteRes;
      }
    } catch (_) {
      // 远程接口异常时保底降级为 Mock
    }
    return _mock.getHomeProductData();
  }

  @override
  Future<ApiResponse<ProductDetail>> getProductDetail(String productId) => _mock.getProductDetail(productId);

  @override
  Future<ApiResponse<ProductListResult>> getProductList({
    required int page,
    required int pageSize,
    String? categoryId,
    String? keyword,
    String? sortBy,
  }) =>
      _mock.getProductList(page: page, pageSize: pageSize, categoryId: categoryId, keyword: keyword, sortBy: sortBy);

  @override
  Future<ApiResponse<List<ProductCategory>>> getCategories() => _mock.getCategories();

  @override
  Future<ApiResponse<ProductListResult>> searchProducts({
    required String keyword,
    required int page,
    required int pageSize,
  }) =>
      _mock.searchProducts(keyword: keyword, page: page, pageSize: pageSize);
}

final productMixedDataSourceProvider = Provider<ProductMixedDataSource>((ref) {
  return ProductMixedDataSource(apiClient: ref.read(apiClientProvider));
});
