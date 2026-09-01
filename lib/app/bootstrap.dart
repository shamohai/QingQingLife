import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

import 'config/app_config.dart';
import 'app.dart';
import '../core/update/shiply/shiply_initializer.dart';
import '../core/logging/logging_initializer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 注册 fluwx
  try {
    await fluwx.Fluwx().registerApi(appId: AppConfig.wechatAppId);
  } catch (e) {
    debugPrint('[Bootstrap] fluwx register failed (expected with placeholder): $e');
  }

  // 初始化 Shiply SDK
  try {
    await ShiplyInitializer.initialize(appVersion: AppConfig.appVersionName, appVersionCode: AppConfig.appVersionCode);
  } catch (e) {
    debugPrint('[Bootstrap] Shiply init failed: $e');
  }

  // 初始化日志系统（LogBuffer + RemoteLogUploader → 自建日志 API）
  try {
    await LoggingInitializer.initialize(logEndpoint: '${AppConfig.baseUrl}/api/app-log/batch');
  } catch (e) {
    debugPrint('[Bootstrap] Logging init failed (non-fatal): $e');
  }

  runApp(const ProviderScope(child: App()));
}
