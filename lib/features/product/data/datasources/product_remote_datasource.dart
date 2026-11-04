/// 商品远程数据源（真实 API）
///
/// 通过 ApiClient 调用后端接口，对接规范参考 points_remote_datasource.dart
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../home/data/models/carousel_model.dart';
import '../../../home/data/models/home_info_model.dart';
import '../../../home/data/models/weimeng_activity_location.dart';

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

  // ── 首页 4 个模块接口 (POST /api/common/app/gethomeinfo) ───────────────────────

  @override
  Future<ApiResponse<HomeProductData>> getHomeProductData() async {
    final response = await _apiClient.post<HomeInfoModel>(
      '/api/common/app/gethomeinfo',
      fromJson: (dynamic json) => HomeInfoModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      return ApiResponse.error(response.message, code: response.code);
    }
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

  /// 获取活动 H5 所需的 SSO Token 与经纬度解析位置。
  ///
  /// 1. 调用 `/api/sys/getssotoken` 获取 `ssotoken`
  /// 2. 获取设备经纬度，并调用 `/api/common/resolvelocation` 解析 `provincename` 与 `cityname`
  @override
  Future<ApiResponse<WeimengActivityLocation>> getWeimengActivityLocation() async {
    // 1. 获取 SSO Token
    final ssoResponse = await _apiClient.post<String>(
      '/api/sys/getssotoken',
      data: <String, dynamic>{},
      fromJson: (dynamic json) {
        if (json is Map<String, dynamic>) {
          return json['ssotoken'] as String? ?? '';
        }
        return json?.toString() ?? '';
      },
    );

    if (!ssoResponse.success || ssoResponse.data == null || ssoResponse.data!.isEmpty) {
      return ApiResponse.error(ssoResponse.message.isEmpty ? '获取授权 Token 失败' : ssoResponse.message);
    }
    final accessToken = ssoResponse.data!;

    // 2. 获取设备经纬度（支持 Web 浏览器定位及默认北京经纬度降级）
    final position = await _getDevicePosition();

    final longitude = position.longitude.toString();
    final latitude = position.latitude.toString();

    // 3. 从经纬度解析省份和城市
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

    if (!locationResponse.success || locationResponse.data == null) {
      return ApiResponse.error(locationResponse.message.isEmpty ? '解析位置信息失败' : locationResponse.message);
    }

    final resolveData = locationResponse.data!;
    return ApiResponse.success(
      WeimengActivityLocation(
        accessToken: accessToken,
        longitude: longitude,
        latitude: latitude,
        province: resolveData.provinceName,
        area: resolveData.cityName,
      ),
    );
  }

  Future<Position> _getDevicePosition() async {
    if (kIsWeb) {
      try {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          return await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 5)),
          );
        }
      } catch (_) {
        // Web 环境降级使用默认位置
      }
      return _defaultPosition();
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final lastPos = await Geolocator.getLastKnownPosition();
        return lastPos ?? _defaultPosition();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          final lastPos = await Geolocator.getLastKnownPosition();
          return lastPos ?? _defaultPosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        final lastPos = await Geolocator.getLastKnownPosition();
        return lastPos ?? _defaultPosition();
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 5)),
      );
    } catch (_) {
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) return lastPos;
      } catch (_) {}
      return _defaultPosition();
    }
  }

  static Position _defaultPosition() {
    return Position(
      longitude: 116.4074,
      latitude: 39.9042,
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

  @override
  Future<ApiResponse<ProductDetail>> getProductDetail(String productId) async {
    throw UnimplementedError('getProductDetail not implemented in ProductRemoteDataSource');
  }

  @override
  Future<ApiResponse<ProductListResult>> getProductList({required int page, required int pageSize, String? categoryId, String? keyword, String? sortBy}) async {
    throw UnimplementedError('getProductList not implemented in ProductRemoteDataSource');
  }

  @override
  Future<ApiResponse<List<ProductCategory>>> getCategories() async {
    throw UnimplementedError('getCategories not implemented in ProductRemoteDataSource');
  }

  @override
  Future<ApiResponse<ProductListResult>> searchProducts({required String keyword, required int page, required int pageSize}) async {
    throw UnimplementedError('searchProducts not implemented in ProductRemoteDataSource');
  }
}

class _LocationResolveData {
  final String provinceName;
  final String cityName;

  _LocationResolveData({required this.provinceName, required this.cityName});

  factory _LocationResolveData.fromJson(Map<String, dynamic> json) {
    return _LocationResolveData(provinceName: json['provincename'] as String? ?? '', cityName: json['cityname'] as String? ?? '');
  }
}

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource(apiClient: ref.read(apiClientProvider));
});
