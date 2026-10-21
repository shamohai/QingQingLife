/// 商品远程数据源（真实 API）
///
/// 通过 ApiClient 调用后端接口，对接规范参考 points_remote_datasource.dart
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../home/data/models/carousel_model.dart';

/// 商品远程数据源
class ProductRemoteDataSource implements ProductRepository {
  final ApiClient _apiClient;

  ProductRemoteDataSource({required this._apiClient});

  // ── 首页轮播图 ──────────────────────────────────────────────────────────────

  @override
  Future<ApiResponse<List<CarouselBanner>>> getCarouselList({required CarouselType type}) async {
    final response = await _apiClient.post<CarouselListData>(
      '/api/common/v3/getcarousellist',
      data: <String, dynamic>{'type': type.value},
      fromJson: (dynamic json) => CarouselListData.fromJson(json as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      return ApiResponse.error(response.message, code: response.code);
    }
    return ApiResponse.success(response.data!.banners);
  }

  // ── 以下方法占位，待对应接口就绪后实现 ─────────────────────────────────────

  @override
  Future<ApiResponse<HomeProductData>> getHomeProductData() async {
    throw UnimplementedError('getHomeProductData not implemented in ProductRemoteDataSource');
  }

  @override
  Future<ApiResponse<ProductDetail>> getProductDetail(String productId) async {
    throw UnimplementedError('getProductDetail not implemented in ProductRemoteDataSource');
  }

  @override
  Future<ApiResponse<ProductListResult>> getProductList({
    required int page,
    required int pageSize,
    String? categoryId,
    String? keyword,
    String? sortBy,
  }) async {
    throw UnimplementedError('getProductList not implemented in ProductRemoteDataSource');
  }

  @override
  Future<ApiResponse<List<ProductCategory>>> getCategories() async {
    throw UnimplementedError('getCategories not implemented in ProductRemoteDataSource');
  }

  @override
  Future<ApiResponse<ProductListResult>> searchProducts({
    required String keyword,
    required int page,
    required int pageSize,
  }) async {
    throw UnimplementedError('searchProducts not implemented in ProductRemoteDataSource');
  }
}

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource(apiClient: ref.read(apiClientProvider));
});
