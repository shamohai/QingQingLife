import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

import 'config/app_config.dart';
import 'app.dart';

/// 应用启动前的引导初始化过程
///
/// 负责初始化第三方 SDK、日志系统和核心服务，确保应用在正式启动前处于就绪状态。
Future<void> bootstrap() async {
  // 确保 Flutter 框架绑定已初始化，这对于调用原生插件是必须的
  WidgetsFlutterBinding.ensureInitialized();

  // 日志必须先于第三方 SDK 初始化，才能记录启动阶段的失败。
  // try {
  //   await LoggingInitializer.initialize(logEndpoint: '${AppConfig.baseUrl}/api/app-log/batch');
  //   AppLogger.info('Local log file: ${LoggingInitializer.localFilePath}', module: 'bootstrap');
  // } catch (e, stackTrace) {
  //   AppLogger.error('Logging init failed (non-fatal)', module: 'bootstrap', error: e, stackTrace: stackTrace);
  // }

  // 微信 SDK 注册：放入后台异步执行，避免阻塞首帧渲染
  // registerApi 在真机上可能耗时较长（特别是微信未安装时），不应阻塞 UI 启动
  unawaited(_registerWeChatAsync());

  // 使用 Riverpod 的 ProviderScope 包裹根 Widget，开启状态管理
  runApp(const ProviderScope(child: App()));
}

// 异步注册微信 SDK，不阻塞启动流程
Future<void> _registerWeChatAsync() async {
  try {
    await fluwx.Fluwx().registerApi(appId: AppConfig.wechatAppId);
  } catch (_) {
    // 微信注册失败不阻塞 App 启动。
  }
}
