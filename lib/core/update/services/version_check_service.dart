import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/update_info.dart';
import '../../../app/config/app_config.dart';

/// 版本检查服务
class VersionCheckService {
  final Dio _dio;

  VersionCheckService(this._dio);

  Future<UpdateInfo> check({
    required int localVersionCode,
    required String localVersionName,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/api/app/version/check',
        queryParameters: {
          'platform': _getPlatform(),
          'versionCode': localVersionCode,
          'versionName': localVersionName,
        },
      );
      final data = response.data as Map<String, dynamic>? ?? {};
      return UpdateInfo.fromJson(data);
    } catch (_) {
      return UpdateInfo(
        versionCode: localVersionCode,
        versionName: localVersionName,
        updateContent: '',
      );
    }
  }

  String _getPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return 'android';
      case TargetPlatform.iOS: return 'ios';
      default: return 'unknown';
    }
  }
}
