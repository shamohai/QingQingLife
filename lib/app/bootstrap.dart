import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

import 'config/app_config.dart';
import 'app.dart';
import '../core/analytics/umeng_analytics.dart';
// [日志调试-已注释] import '../core/logging/app_logger.dart';
// [日志调试-已注释] import '../core/logging/log_buffer.dart';
import '../core/update/services/startup_video_update_service_stub.dart' if (dart.library.io) '../core/update/services/startup_video_update_service.dart';

/// 应用启动前的引导初始化过程
///
/// 负责初始化第三方 SDK、日志系统和核心服务，确保应用在正式启动前处于就绪状态。
Future<void> bootstrap() async {
  // 确保 Flutter 框架绑定已初始化，这对于调用原生插件是必须的
  WidgetsFlutterBinding.ensureInitialized();

  // [日志调试-已注释] 日志缓冲区：写入应用目录（外部存储优先），便于真机导出排查问题。初始化失败不影响启动。
  // [日志调试-已注释] try {
  // [日志调试-已注释]   final buffer = LogBuffer();
  // [日志调试-已注释]   await buffer.init();
  // [日志调试-已注释]   AppLogger.init(buffer: buffer);
  // [日志调试-已注释]   AppLogger.info('日志缓冲区已启用: ${buffer.localFilePath}', module: 'bootstrap');
  // [日志调试-已注释] } catch (e) {
  // [日志调试-已注释]   AppLogger.warning('日志缓冲区初始化失败（不影响启动）', module: 'bootstrap', error: e);
  // [日志调试-已注释] }

  // 微信 SDK 注册：放入后台异步执行，避免阻塞首帧渲染
  // registerApi 在真机上可能耗时较长（特别是微信未安装时），不应阻塞 UI 启动
  unawaited(_registerWeChatAsync());

  // 友盟统计：仅当用户此前已在登录页同意隐私政策时才初始化，后台执行不阻塞首帧。
  unawaited(UmengAnalytics().initIfConsented());

  // 先覆盖记录安装包构建号（本地操作，耗时极短），保证后续 CheckUpdate 请求读取到一致的本地状态。
  await StartupVideoUpdateService().syncAppBuildOnLaunch();

  // 自有服务器热更新：后台静默检测并下载，不阻塞首帧。
  // 下载结果在下次启动时生效（启动视频 open.mp4 更新后会重新播放）。
  // Web 平台通过条件导入的 stub 实现，checkAndDownloadUpdate 直接返回 false。
  unawaited(StartupVideoUpdateService().checkAndDownloadUpdate());

  // 使用 Riverpod 的 ProviderScope 包裹根 Widget，开启状态管理
  runApp(const ProviderScope(child: App()));
}

// 异步注册微信 SDK，不阻塞启动流程
Future<void> _registerWeChatAsync() async {
  await fluwx.Fluwx().registerApi(
    appId: AppConfig.wechatAppId,
    universalLink: AppConfig.wechatUniversalLink,
  );
}
