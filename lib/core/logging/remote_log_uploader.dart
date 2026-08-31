import 'dart:async';
import 'package:dio/dio.dart';
import 'log_buffer.dart';
import 'log_context.dart';

/// 远程日志批量上传服务
///
/// - 定时器每 60 秒检查一次，满足 batchSize 或队列非空时触发上传
/// - 上传失败自动重试，最多 3 次，指数退避（2s / 4s / 8s）
/// - 每次上传携带当前 [LogContext]（traceId / userId / appVersion 等）
/// - 上传成功清空已上传条目，失败则保留在缓冲区等待下次重试
class RemoteLogUploader {
  final LogBuffer buffer;
  final Dio dio;
  final String logEndpoint;
  final int batchSize;
  static const int maxRetries = 3;
  static const Duration baseRetryDelay = Duration(seconds: 2);

  Timer? _uploadTimer;
  bool _uploading = false;

  RemoteLogUploader({
    required this.buffer,
    required this.dio,
    required this.logEndpoint,
    this.batchSize = 20,
  });

  void startAutoUpload() {
    buffer.onNewEntries = (_) => _maybeUpload();
    _uploadTimer = Timer.periodic(const Duration(minutes: 1), (_) => _maybeUpload());
  }

  void stop() {
    _uploadTimer?.cancel();
    _uploadTimer = null;
  }

  void _maybeUpload() {
    if (_uploading) return;
    if (buffer.length >= batchSize || buffer.length > 0) _upload();
  }

  Future<void> _upload() async {
    if (_uploading) return;
    _uploading = true;
    var attempt = 0;
    while (attempt <= maxRetries) {
      try {
        final entries = buffer.getEntries(limit: 100);
        if (entries.isEmpty) return;

        // 获取当前上下文（traceId / userId / appVersion 等）
        final payload = entries.map((e) {
          final map = e.toJson();
          map['context'] = LogContext.newTrace().toJson();
          return map;
        }).toList();

        await dio.post(
          logEndpoint,
          data: {'logs': payload},
          options: Options(
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        // 上传成功，清空已上传条目
        buffer.clear();
        return;
      } catch (e) {
        attempt++;
        if (attempt > maxRetries) {
          // 放弃，保留在缓冲区，等待下次定时重试
          break;
        }
        await Future.delayed(baseRetryDelay * (1 << (attempt - 1)));
      } finally {
        _uploading = false;
      }
    }
  }
}