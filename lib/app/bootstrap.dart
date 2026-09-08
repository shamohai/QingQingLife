import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

import 'config/app_config.dart';
import 'app.dart';
import '../core/update/shiply/shiply_initializer.dart';
import '../core/logging/app_logger.dart';
import '../core/logging/logging_initializer.dart';

/// 应用启动前的引导初始化过程
///
/// 负责初始化第三方 SDK、日志系统和核心服务，确保应用在正式启动前处于就绪状态。
Future<void> bootstrap() async {
  // 确保 Flutter 框架绑定已初始化，这对于调用原生插件是必须的
  WidgetsFlutterBinding.ensureInitialized();

  // 日志必须先于第三方 SDK 初始化，才能记录启动阶段的失败。
  try {
    await LoggingInitializer.initialize(logEndpoint: '${AppConfig.baseUrl}/api/app-log/batch');
    AppLogger.info('Local log file: ${LoggingInitializer.localFilePath}', module: 'bootstrap');
  } catch (e, stackTrace) {
    debugPrint('[Bootstrap] Logging init failed (non-fatal): $e\n$stackTrace');
  }

  if (LoggingInitializer.isInitialized) {
    AppLogger.info('Registering WeChat appId=${AppConfig.wechatAppId}', module: 'wechat', event: 'register_start');
  }

  // 注册微信 SDK (fluwx)
  try {
    final registered = await fluwx.Fluwx().registerApi(appId: AppConfig.wechatAppId);
    if (LoggingInitializer.isInitialized) {
      AppLogger.info('registerApi returned=$registered', module: 'wechat', event: 'register_result');
    }
  } catch (e, stackTrace) {
    if (LoggingInitializer.isInitialized) {
      AppLogger.error('registerApi failed', module: 'wechat', event: 'register_error', error: e, stackTrace: stackTrace);
    } else {
      debugPrint('[Bootstrap][WeChat] registerApi failed: $e\n$stackTrace');
    }
  }

  // 初始化 Shiply SDK
  // 用于实现 App 的热更新和灰度发布功能，需要在应用早期加载
  try {
    await ShiplyInitializer.initialize(appVersion: AppConfig.appVersionName, appVersionCode: AppConfig.appVersionCode);
  } catch (e) {
    debugPrint('[Bootstrap] Shiply init failed: $e');
  }

  // 使用 Riverpod 的 ProviderScope 包裹根 Widget，开启状态管理
  runApp(const ProviderScope(child: App()));
}
