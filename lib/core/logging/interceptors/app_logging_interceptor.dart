import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../app_logger.dart';

/// Dio 请求/响应日志拦截器
///
/// - 为每次请求生成 traceId，通过 header / extra 传递
/// - 记录请求耗时，自动附加到 http_success / http_error 事件中
/// - Debug 模式输出详细请求 URL，Release 仅记录结果
class AppLoggingInterceptor extends Interceptor {
  static const _traceIdHeader = '__trace_id';
  static const _startTimeKey = '_log_request_start';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[_traceIdHeader] = const Uuid().v4();
    options.extra[_traceIdHeader] = options.headers[_traceIdHeader];
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;

    if (kDebugMode) {
      AppLogger.debug(
        '[HTTP] ${options.method} ${options.uri.path}',
        module: 'network',
        data: {'url': options.uri.toString()},
      );
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra[_startTimeKey] as int?;
    final traceId = response.requestOptions.extra[_traceIdHeader] as String?;
    final elapsed = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : null;

    AppLogger.info(
      '[HTTP] ${response.statusCode} ${response.requestOptions.uri.path} ${elapsed != null ? '(${elapsed}ms)' : ''}',
      module: 'network',
      event: 'http_success',
      data: {
        'statusCode': response.statusCode,
        'elapsedMs': elapsed,
        'traceId': traceId,
      },
    );
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra[_startTimeKey] as int?;
    final traceId = err.requestOptions.extra[_traceIdHeader] as String?;
    final elapsed = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : null;

    AppLogger.error(
      '[HTTP] ${err.type} ${err.response?.statusCode ?? '?'} ${err.requestOptions.uri.path} ${elapsed != null ? '(${elapsed}ms)' : ''}',
      module: 'network',
      event: 'http_error',
      error: err,
      data: {
        'dioType': err.type.name,
        'statusCode': err.response?.statusCode,
        'elapsedMs': elapsed,
        'traceId': traceId,
      },
    );
    return handler.next(err);
  }
}