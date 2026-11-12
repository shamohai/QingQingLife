import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../../home/data/models/carousel_model.dart';
import '../../../home/data/models/home_info_model.dart';
import '../../../home/data/models/weimeng_activity_location.dart';
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
    try {
      final response = await _apiClient!.post<CarouselListData>(
        '/api/common/v3/getcarousellist',
        data: <String, dynamic>{'type': type.value},
        fromJson: (dynamic json) => CarouselListData.fromJson(json as Map<String, dynamic>),
      );
      if (response.success && response.data != null) {
        return ApiResponse.success(response.data!.banners);
      }
    } catch (_) {}
    return ApiResponse.success([]);
  }

  // ── 首页 4 个模块接口 (POST /api/common/app/gethomeinfo) ───────────────────────
  @override
  Future<ApiResponse<HomeProductData>> getHomeProductData() async {
    try {
      final response = await _apiClient!.post<HomeInfoModel>(
        '/api/common/app/gethomeinfo',
        fromJson: (dynamic json) => HomeInfoModel.fromJson(json as Map<String, dynamic>),
      );
      if (response.success && response.data != null) {
        final info = response.data!;
        final homeData = HomeProductData(
          banners: const [],
          kingKongItems: info.toKingKongItems(),
          newUserGifts: const [],
          hotProducts: const [],
          hotSearchKeywords: const [],
          topicActivities: const {},
          monthlyBenefits: info.toMonthlyBenefits(),
          activityBlocks: info.toActivityBlocks(),
          topicActivityBlocks: info.toTopicActivityBlocks(),
        );
        return ApiResponse.success(homeData);
      }
    } catch (_) {}

    // 降级使用基础本地数据
    return ApiResponse.success(
      HomeProductData(
        banners: [HomeBanner(imageUrl: 'assets/images/home/banner_1.png', title: '特产热卖', actionUrl: '/activity/special')],
        kingKongItems: [],
        newUserGifts: [],
        hotProducts: [],
        hotSearchKeywords: ['青稞酒', '牛肉干', '菜籽油', '枸杞'],
        topicActivities: const {},
        activityBlocks: [],
        topicActivityBlocks: [],
        monthlyBenefits: [],
      ),
    );
  }

  // ── 经纬度与 H5 SSO Token ───────────────────────────────────────────────────
  @override
  Future<ApiResponse<WeimengActivityLocation>> getWeimengActivityLocation() async {
    try {
      final ssoResponse = await _apiClient!.post<String>(
        '/api/sys/getssotoken',
        data: <String, dynamic>{},
        fromJson: (dynamic json) {
          if (json is Map<String, dynamic>) {
            return json['ssotoken'] as String? ?? '';
          }
          return json?.toString() ?? '';
        },
      );

      if (ssoResponse.success && ssoResponse.data != null && ssoResponse.data!.isNotEmpty) {
        final accessToken = ssoResponse.data!;
        Position position;
        try {
          position = await _getDevicePosition();
        } catch (_) {
          position = _defaultPosition();
        }

        final locationResponse = await _apiClient.post<_LocationResolveData>(
          '/api/common/resolvelocation',
          data: <String, dynamic>{
            'lnglat': [position.longitude, position.latitude],
          },
          fromJson: (dynamic json) {
            if (json is Map<String, dynamic>) {
              return _LocationResolveData.fromJson(json);
            }
            return _LocationResolveData(provinceName: '', cityName: '');
          },
        );

        final resolveData = locationResponse.data ?? _LocationResolveData(provinceName: '青海省', cityName: '西宁市');
        return ApiResponse.success(
          WeimengActivityLocation(
            accessToken: accessToken,
            longitude: position.longitude.toString(),
            latitude: position.latitude.toString(),
            province: resolveData.provinceName,
            area: resolveData.cityName,
          ),
        );
      }
    } catch (_) {}

    return ApiResponse.error('获取活动位置失败，请稍后重试');
  }

  Future<Position> _getDevicePosition() async {
    if (kIsWeb) return _defaultPosition();
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _defaultPosition();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return _defaultPosition();
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 5)),
      );
    } catch (_) {
      return _defaultPosition();
    }
  }

  static Position _defaultPosition() {
    return Position(
      longitude: 101.7782,
      latitude: 36.6171,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  // ── 商品详情与分类列表 ─────────────────────────────────────────────────────
  @override
  Future<ApiResponse<ProductDetail>> getProductDetail(String productId) async {
    return ApiResponse.error('商品详情接口暂未接入');
  }

  @override
  Future<ApiResponse<ProductListResult>> getProductList({required int page, required int pageSize, String? categoryId, String? keyword, String? sortBy}) async {
    return ApiResponse.success(ProductListResult(products: const [], total: 0, page: page, pageSize: pageSize, hasMore: false));
  }

  @override
  Future<ApiResponse<List<ProductCategory>>> getCategories() async {
    return ApiResponse.success(const []);
  }

  @override
  Future<ApiResponse<ProductListResult>> searchProducts({required String keyword, required int page, required int pageSize}) async {
    return getProductList(page: page, pageSize: pageSize, keyword: keyword);
  }

  // ── ProductDetailContentRepository 结构化详情 ─────────────────────────────
  @override
  Future<ProductDetailContent?> getDetail(String id) async => null;
}

class _LocationResolveData {
  final String provinceName;
  final String cityName;

  _LocationResolveData({required this.provinceName, required this.cityName});

  factory _LocationResolveData.fromJson(Map<String, dynamic> json) {
    return _LocationResolveData(provinceName: json['provincename'] as String? ?? '', cityName: json['cityname'] as String? ?? '');
  }
}

final productDataSourceProvider = Provider<ProductDataSource>((ref) {
  return ProductDataSource(apiClient: ref.read(apiClientProvider));
});
