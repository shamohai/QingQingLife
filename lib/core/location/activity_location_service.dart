import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/home/data/models/weimeng_activity_location.dart';
import '../network/api_client.dart';
import '../network/api_response.dart';
import '../network/providers.dart';

/// 活动定位服务：获取 H5 SSO token，并用已确认的定位解析省市信息。
/// 定位本身由调用方先完成，保证定位失败时不发起 SSO 与解析请求。
class ActivityLocationService {
  final ApiClient _apiClient;

  ActivityLocationService({required this._apiClient});

  /// 获取微盟酒王 H5 所需的授权和位置参数。
  Future<ApiResponse<WeimengActivityLocation>> getWeimengActivityLocation({required Position position}) async {
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
    if (!ssoResponse.success) return ApiResponse.error(ssoResponse.message, code: ssoResponse.code);
    final accessToken = ssoResponse.data;
    if (accessToken == null || accessToken.isEmpty) return ApiResponse.error('获取活动位置失败，请稍后重试');

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
    if (!locationResponse.success) return ApiResponse.error(locationResponse.message, code: locationResponse.code);
    final resolveData = locationResponse.data;
    if (resolveData == null) return ApiResponse.error('获取活动位置失败，请稍后重试');

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
}

class _LocationResolveData {
  final String provinceName;
  final String cityName;

  _LocationResolveData({required this.provinceName, required this.cityName});

  factory _LocationResolveData.fromJson(Map<String, dynamic> json) {
    return _LocationResolveData(provinceName: json['provincename'] as String? ?? '', cityName: json['cityname'] as String? ?? '');
  }
}

final activityLocationServiceProvider = Provider<ActivityLocationService>((ref) {
  return ActivityLocationService(apiClient: ref.read(apiClientProvider));
});
