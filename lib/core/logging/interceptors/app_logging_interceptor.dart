import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:uuid/uuid.dart';

import '../app_logger.dart';
import '../../utils/common_utils.dart';

/// Dio request/response logging interceptor.
/// Logs full request params/body before send and response body after receive.
class AppLoggingInterceptor extends Interceptor {
  static const _traceIdHeader = '__trace_id';
  static const _startTimeKey = '_log_request_start';

  static String safeEncode(dynamic value) => CommonUtils.safeEncode(value);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    //web测试时，会出现跨越问题
    final traceId = const Uuid().v4();
    // 需要发给服务端时才加 header（web 注意 CORS）
    if (!kIsWeb) {
      options.headers[_traceIdHeader] = traceId;
    }

    options.extra[_traceIdHeader] = traceId;
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final uri = response.requestOptions.uri;

    if (kDebugMode) {
      if (kIsWeb) {
        debugPrint('${uri.path} 接口Response返回数据：${safeEncode(response.data)}');
      }
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra[_startTimeKey] as int?;
    final traceId = err.requestOptions.extra[_traceIdHeader] as String?;
    final elapsed = startTime != null ? DateTime.now().millisecondsSinceEpoch - startTime : null;
    final uri = err.requestOptions.uri;

    if (kDebugMode) {
      debugPrint('\u2550' * 38);
      debugPrint('[HTTP ERROR] ${err.type} ${err.response?.statusCode?.toString() ?? '?'} ${uri.path} (${elapsed?.toString() ?? '?'}ms)');
      debugPrint('\u2550' * 38);
      if (err.response?.data != null) {
        debugPrint('[Error Response Body]');
        debugPrint(safeEncode(err.response!.data));
        debugPrint('');
      }
    }

    AppLogger.error(
      '[HTTP] ${err.type} ${err.response?.statusCode?.toString() ?? '?'} ${uri.path} (${elapsed?.toString() ?? '?'}ms)',
      module: 'network',
      event: 'http_error',
      error: err,
      data: {'dioType': err.type.name, 'statusCode': err.response?.statusCode, 'elapsedMs': elapsed, 'traceId': traceId},
    );
    if (err.response?.data != null) {
      AppLogger.rawInfo(
        '[HTTP ERROR RESPONSE BODY] ${uri.path}: ${safeEncode(err.response!.data)}',
        module: 'network',
        event: 'http_error_response_raw',
        data: {
          'method': err.requestOptions.method,
          'url': uri.toString(),
          'statusCode': err.response?.statusCode,
          'elapsedMs': elapsed,
          'traceId': traceId,
          'body': err.response!.data,
        },
      );
    }
    return handler.next(err);
  }
}
