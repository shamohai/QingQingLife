import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'app_logger.dart';
import 'log_buffer.dart';
import 'log_entry.dart';
import 'remote_log_uploader.dart';

/// 日志系统统一初始化器
///
/// 在 [main] 或 [bootstrap] 中调用一次，完成：
///   1. LogBuffer 创建并加载本地历史日志
///   2. AppLogger 初始化（注入 Talker + LogBuffer）
///   3. 全局异常捕获（FlutterError / PlatformDispatcher）
///   4. RemoteLogUploader 启动（异步批量上传到自建日志 API）
///
/// 日志流向：
///   AppLogger → Talker（控制台）
///             → LogBuffer → RemoteLogUploader → POST {logEndpoint}
class LoggingInitializer {
  static LogBuffer? _buffer;

  static bool get isInitialized => _buffer != null;

  /// [logEndpoint]           - 自建日志 API 地址
  /// [batchSize]             - 触发上传的最小条数，默认 20
  /// [debugModuleThreshold]  - debug 模式下各模块的最低日志级别覆盖
  static Future<void> initialize({
    required String logEndpoint,
    int batchSize = 20,
    Map<String, AppLogLevel>? debugModuleThreshold,
  }) async {
    if (_buffer != null) return;

    // 1. 初始化缓冲区
    _buffer = LogBuffer();
    await _buffer!.init();

    // 2. 初始化 AppLogger
    AppLogger.init(buffer: _buffer);

    // 3. debug 模块级别覆盖
    if (kDebugMode && debugModuleThreshold != null) {
      for (final entry in debugModuleThreshold.entries) {
        AppLogger.setModuleLevel(entry.key, entry.value);
      }
    }

    // 4. 启动远程上传
    RemoteLogUploader(
      buffer: _buffer!,
      dio: Dio(),
      logEndpoint: logEndpoint,
      batchSize: batchSize,
    ).startAutoUpload();

    // 5. 全局异常捕获
    _installGlobalHandlers();

    AppLogger.info(
      'Logging system initialized',
      module: 'logging',
      event: 'logging_init',
      data: {'logEndpoint': logEndpoint, 'batchSize': batchSize},
    );
  }

  static void _installGlobalHandlers() {
    FlutterError.onError = (details) {
      AppLogger.error(
        'FlutterError: ${details.exception}',
        module: 'flutter',
        event: 'flutter_error',
        error: details.exception,
        stackTrace: details.stack,
      );
      FlutterError.dumpErrorToConsole(details, forceReport: true);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      AppLogger.error(
        'PlatformDispatcher error: $error',
        module: 'system',
        event: 'platform_error',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    };
  }

  static LogBuffer? get buffer => _buffer;

  static void shutdown() {
    _buffer?.onNewEntries = null;
    _buffer = null;
  }
}