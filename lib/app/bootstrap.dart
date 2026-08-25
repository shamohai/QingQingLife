import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

import 'config/app_config.dart';
import 'app.dart';

/// App 启动入口，初始化 ProviderScope、fluwx 并运行 App
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 注册 fluwx（使用占位 AppID，真实 AppID 替换 AppConfig.wechatAppId 后生效）
  try {
    await fluwx.Fluwx().registerApi(appId: AppConfig.wechatAppId);
  } catch (e) {
    debugPrint('[Bootstrap] fluwx register failed (expected with placeholder): ');
  }
  runApp(const ProviderScope(child: App()));
}
