import 'package:qingqinglife/core/logging/app_logger.dart';

import 'shiply_config.dart';

/// Shiply SDK 初始化封装
class ShiplyInitializer {
  static Future<void> initialize({required String appVersion, required int appVersionCode}) async {
    if (!ShiplyConfig.enabled) {
      AppLogger.info('Disabled by config.', module: 'shiply');
      return;
    }
    if (_isGooglePlayBuild()) {
      AppLogger.info('Google Play build detected, hotfix disabled.', module: 'shiply');
      return;
    }
    try {
      // TODO: 接入 shiply_flutter 后取消注释
    } catch (e) {
      AppLogger.error('Init failed', module: 'shiply', error: e);
    }
  }

  static bool _isGooglePlayBuild() {
    // TODO: 根据实际渠道配置调整
    return false;
  }
}
