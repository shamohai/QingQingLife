import 'package:talker_flutter/talker_flutter.dart';
import 'log_entry.dart';
import 'log_buffer.dart';
import 'log_sanitizer.dart';

/// 统一日志入口，所有业务代码必须通过此类记录日志
///
/// 日志流向：
///
/// ```
/// AppLogger
///   ↓
/// Talker（控制台输出）
/// LogBuffer（本地持久化）
///   ↓
/// RemoteLogUploader（异步批量 POST → 自建日志 API）
/// ```
///
/// **禁止**：业务代码直接使用 `Talker`、`print`、`debugPrint`。
class AppLogger {
  static late final Talker _talker;
  static LogBuffer? _buffer;
  static final Map<String, AppLogLevel> _moduleLevels = {};

  static void init({LogBuffer? buffer, Talker? talker}) {
    _buffer = buffer;
    _talker = talker ?? Talker();
  }

  // ── 公开 API ──────────────────────────────────────────────────────

  static void debug(String message, {String? module, Map<String, dynamic>? data}) {
    _log(AppLogLevel.debug, message, module: module, data: data);
  }

  static void info(String message, {String? module, String? event, Map<String, dynamic>? data}) {
    _log(AppLogLevel.info, message, module: module, event: event, data: data);
  }

  static void warning(
    String message, {
    String? module,
    String? event,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) =>
      _log(AppLogLevel.warning, message,
          module: module, event: event, error: error, stackTrace: stackTrace, data: data);

  static void error(
    String message, {
    String? module,
    String? event,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) =>
      _log(AppLogLevel.error, message,
          module: module, event: event, error: error, stackTrace: stackTrace, data: data);

  static void critical(
    String message, {
    String? module,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) =>
      _log(AppLogLevel.critical, message,
          module: module, error: error, stackTrace: stackTrace, data: data);

  static void setModuleLevel(String module, AppLogLevel level) {
    _moduleLevels[module] = level;
  }

  // ── 内部实现 ──────────────────────────────────────────────────────

  static void _log(
    AppLogLevel level,
    String message, {
    String? module,
    String? event,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (module != null) {
      final threshold = _moduleLevels[module];
      if (threshold != null && level.index < threshold.index) return;
    }
    if (!const bool.fromEnvironment('flutter.debug') && level == AppLogLevel.debug) return;

    final sanitizedMessage = LogSanitizer.sanitize(message);
    final sanitizedData = data != null ? LogSanitizer.sanitizeData(data) : null;

    // 写入缓冲区 → RemoteLogUploader → 自建日志 API
    _buffer?.add(LogEntry(
      level: level,
      message: sanitizedMessage,
      module: module,
      event: event,
      error: error,
      stackTrace: stackTrace,
      data: sanitizedData,
      timestamp: DateTime.now(),
    ));

    // Talker 控制台输出
    final prefix = '[${module ?? "?"}]';
    switch (level) {
      case AppLogLevel.debug:
        _talker.debug('$prefix $sanitizedMessage');
        break;
      case AppLogLevel.info:
        _talker.info('$prefix $sanitizedMessage');
        break;
      case AppLogLevel.warning:
        _talker.warning('$prefix $sanitizedMessage ${error != null ? "- $error" : ""}');
        break;
      case AppLogLevel.error:
        _talker.error('$prefix $sanitizedMessage', error, stackTrace ?? StackTrace.current);
        break;
      case AppLogLevel.critical:
        _talker.error('$prefix $sanitizedMessage', error, stackTrace ?? StackTrace.current);
        break;
    }
  }
}