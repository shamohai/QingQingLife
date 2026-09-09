import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

import 'log_entry.dart';

/// 内存日志缓冲区 + 本地持久化
///
/// - 内存队列上限 [_maxMemorySize] 条，超出按 FIFO 淘汰
/// - 本地文件容量上限 [_maxLocalSize] 条，超出按时间淘汰旧条目
/// - 支持过期清理： [_maxAgeHours] 之前的日志自动移除
class LogBuffer {
  static const _maxMemorySize = 200;
  static const _maxLocalSize = 1000;
  static const _maxAgeHours = 24;
  static const _localFileKey = 'app_log_buffer.json';

  final List<LogEntry> _queue = [];
  File? _localFile;
  File? _externalFile;

  void Function(List<LogEntry> entries)? onNewEntries;

  Future<void> init() async {
    if (kIsWeb) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      _localFile = File('${dir.path}/$_localFileKey');
      if (Platform.isAndroid) {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          _externalFile = File('${externalDir.path}/$_localFileKey');
        }
      }
      await _loadFromFile();
      _removeExpired();
    } catch (_) {
      // 在 Web 环境或不支持文件系统的环境，保持内存运行即可
    }
  }

  void add(LogEntry entry) {
    _queue.add(entry);
    if (_queue.length > _maxMemorySize) {
      _queue.removeRange(0, _queue.length - _maxMemorySize);
    }
    _saveToFile();
    onNewEntries?.call(List.from(_queue));
  }

  List<LogEntry> getEntries({int limit = 50}) {
    final entries = List<LogEntry>.from(_queue);
    if (limit < entries.length) return entries.sublist(entries.length - limit);
    return entries;
  }

  void clear() {
    _queue.clear();
    _saveToFile();
  }

  bool get isEmpty => _queue.isEmpty;
  int get length => _queue.length;
  String get localFilePath => _externalFile?.path ?? _localFile?.path ?? 'memory';

  void _removeExpired() {
    final cutoff = DateTime.now().subtract(const Duration(hours: _maxAgeHours));
    _queue.removeWhere((e) => e.timestamp.isBefore(cutoff));
    _saveToFile();
  }

  Future<void> _saveToFile() async {
    if (kIsWeb || _localFile == null) return;
    try {
      final entries = _queue.length > _maxLocalSize ? _queue.sublist(_queue.length - _maxLocalSize) : _queue;
      final content = const JsonEncoder.withIndent('  ').convert(entries.map((e) => e.toJson()).toList());
      await _localFile!.writeAsString(content);
      await _externalFile?.writeAsString(content);
    } catch (_) {}
  }

  Future<void> _loadFromFile() async {
    if (kIsWeb || _localFile == null) return;
    try {
      if (!await _localFile!.exists()) return;
      final content = await _localFile!.readAsString();
      for (final item in jsonDecode(content) as List) {
        _queue.add(_logEntryFromJson(item as Map<String, dynamic>));
      }
    } catch (_) {}
  }
}

LogEntry _logEntryFromJson(Map<String, dynamic> json) {
  final levelName = json['level'] as String?;
  final level = AppLogLevel.values.firstWhere((l) => l.name == levelName, orElse: () => AppLogLevel.info);
  return LogEntry(
    level: level,
    message: json['message'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    module: json['module'] as String?,
    event: json['event'] as String?,
    error: json['error'],
    stackTrace: null,
    data: json['data'] as Map<String, dynamic>?,
  );
}
