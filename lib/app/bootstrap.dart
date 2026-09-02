import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

import 'config/app_config.dart';
import 'app.dart';
import '../core/update/shiply/shiply_initializer.dart';
import '../core/logging/logging_initializer.dart';

/// 应用启动前的引导初始化过程
/// 
/// 负责初始化第三方 SDK、日志系统和核心服务，确保应用在正式启动前处于就绪状态。
Future<void> bootstrap() async {
  // 确保 Flutter 框架绑定已初始化，这对于调用原生插件是必须的
  WidgetsFlutterBinding.ensureInitialized();

  // 注册微信 SDK (fluwx)
  // 用于支持微信登录、分享和支付功能。如果 appId 为空或环境配置不对可能会报错，因此使用 try-catch 包裹
  try {
    await fluwx.Fluwx().registerApi(appId: AppConfig.wechatAppId);
  } catch (e) {
    debugPrint('[Bootstrap] fluwx register failed (expected with placeholder): $e');
  }

  // 初始化 Shiply SDK
  // 用于实现 App 的热更新和灰度发布功能，需要在应用早期加载
  try {
    await ShiplyInitializer.initialize(appVersion: AppConfig.appVersionName, appVersionCode: AppConfig.appVersionCode);
  } catch (e) {
    debugPrint('[Bootstrap] Shiply init failed: $e');
  }

  // 初始化日志系统
  // 建立本地日志缓冲池，并配置异步上传到自建日志分析 API，用于线上问题排查
  try {
    await LoggingInitializer.initialize(logEndpoint: '${AppConfig.baseUrl}/api/app-log/batch');
  } catch (e) {
    debugPrint('[Bootstrap] Logging init failed (non-fatal): $e');
  }

  // 使用 Riverpod 的 ProviderScope 包裹根 Widget，开启状态管理
  runApp(const ProviderScope(child: App()));
}
