import 'package:flutter/foundation.dart';

import 'shiply_config.dart';

/// Shiply SDK 初始化封装
class ShiplyInitializer {
  static Future<void> initialize({
    required String appVersion,
    required int appVersionCode,
  }) async {
    if (!ShiplyConfig.enabled) {
      debugPrint('[Shiply] Disabled by config.');
      return;
    }
    if (_isGooglePlayBuild()) {
      debugPrint('[Shiply] Google Play build detected, hotfix disabled.');
      return;
    }
    try {
      // TODO: 接入 shiply_flutter 后取消注释
      // import 'package:shiply_flutter/shiply_flutter.dart';
      // final appId = defaultTargetPlatform == TargetPlatform.android
      //     ? ShiplyConfig.androidAppId
      //     : ShiplyConfig.iosAppId;
      // await ShiplyFlutter.init(
      //   appId: appId,
      //   appVersion: appVersion,
      //   appVersionCode: appVersionCode,
      // );
      debugPrint('[Shiply] Placeholder init - add shiply_flutter package.');
    } catch (e) {
      debugPrint('[Shiply] Init failed: $e');
    }
  }

  static bool _isGooglePlayBuild() {
    // TODO: 根据实际渠道配置调整
    return false;
  }
}
