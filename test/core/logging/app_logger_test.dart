import 'package:flutter_test/flutter_test.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:qingqinglife/core/logging/app_logger.dart';
import 'package:qingqinglife/core/logging/log_buffer.dart';
import 'package:qingqinglife/core/logging/log_entry.dart';

class _TestLogBuffer extends LogBuffer {
  final List<LogEntry> entries = [];

  @override
  void add(LogEntry entry) => entries.add(entry);

  @override
  List<LogEntry> getEntries({int limit = 50}) => entries.take(limit).toList();
}

void main() {
  test('rawInfo preserves complete response fields in the local log', () async {
    final buffer = _TestLogBuffer();
    AppLogger.init(buffer: buffer, talker: Talker());

    AppLogger.rawInfo(
      'WeChat login response',
      module: 'wechat',
      event: 'login_response_raw',
      data: {
        'accessToken': 'test-access-token',
        'userInfo': {'phone': '13800138000'},
      },
    );

    final entry = buffer.getEntries(limit: 1).single;
    expect(entry.data?['accessToken'], 'test-access-token');
    expect((entry.data?['userInfo'] as Map<String, dynamic>)['phone'], '13800138000');
  });
}
