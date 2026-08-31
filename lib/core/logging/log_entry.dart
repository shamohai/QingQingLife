/// 单条日志条目数据模型
class LogEntry {
  final AppLogLevel level;
  final String message;
  final String? module;
  final String? event;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  const LogEntry({
    required this.level,
    required this.message,
    this.module,
    this.event,
    this.error,
    this.stackTrace,
    this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'level': level.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'module': module,
      'event': event,
    };
    if (error != null) map['error'] = error.toString();
    if (stackTrace != null) map['stackTrace'] = stackTrace.toString();
    if (data != null) map['data'] = data;
    return map;
  }
}

/// 日志等级（业务层定义，避免与 talker 的 LogLevel 冲突）
enum AppLogLevel { debug, info, warning, error, critical }