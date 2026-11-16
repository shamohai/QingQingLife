import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../../home/data/models/carousel_model.dart';
import '../../../home/data/models/home_info_model.dart';
import '../../domain/models/product_detail_content.dart';
import '../../domain/repositories/product_detail_content_repository.dart';
import '../../domain/repositories/product_repository.dart';

/// 统一商品数据源（实现 ProductRepository 与 ProductDetailContentRepository 接口）
class ProductDataSource implements ProductRepository, ProductDetailContentRepository {
  final ApiClient? _apiClient;

  ProductDataSource({this._apiClient});

  // ── 首页轮播图 ──────────────────────────────────────────────────────────────
  @override
  Future<ApiResponse<List<CarouselBanner>>> getCarouselList({required CarouselType type}) async {
    final response = await _apiClient!.post<CarouselListData>(
      '/api/common/v3/getcarousellist',
      data: <String, dynamic>{'type': type.value},
      fromJson: (dynamic json) => CarouselListData.fromJson(json as Map<String, dynamic>),
    );
    if (!response.success) return ApiResponse.error(response.message, code: response.code);
    return ApiResponse.success(response.data?.banners ?? const <CarouselBanner>[]);
  }

  // ── 首页 4 个模块接口 (POST /api/common/app/gethomeinfo) ───────────────────────
  @override
  Future<ApiResponse<HomeProductData>> getHomeProductData() async {
    final response = await _apiClient!.post<HomeInfoModel>(
      '/api/common/app/gethomeinfo',
      fromJson: (dynamic json) => HomeInfoModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.success) return ApiResponse.error(response.message, code: response.code);
    final info = response.data;
    if (info == null) return ApiResponse.error('首页数据为空，请稍后重试');
    return ApiResponse.success(
      HomeProductData(
        banners: const [],
        kingKongItems: info.toKingKongItems(),
        newUserGifts: const [],
        hotProducts: const [],
        hotSearchKeywords: const [],
        topicActivities: const {},
        monthlyBenefits: info.toMonthlyBenefits(),
        activityBlocks: info.toActivityBlocks(),
        topicActivityBlocks: info.toTopicActivityBlocks(),
      ),
    );
  }

  // ── ProductDetailContentRepository 结构化详情 ─────────────────────────────
  // TODO(API): 实物商品详情接口尚未在项目中定义，接口就绪前返回 null，页面展示"暂无商品详情"。
  @override
  Future<ProductDetailContent?> getDetail(String id) async => null;
}

final productDataSourceProvider = Provider<ProductDataSource>((ref) {
  return ProductDataSource(apiClient: ref.read(apiClientProvider));
});
