import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../app_logger.dart';

/// Dio request/response logging interceptor.
/// Logs full request params/body before send and response body after receive.
class AppLoggingInterceptor extends Interceptor {
  static const _traceIdHeader = '__trace_id';
  static const _startTimeKey = '_log_request_start';

  static String _safeEncode(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[_traceIdHeader] = const Uuid().v4();
    options.extra[_traceIdHeader] = options.headers[_traceIdHeader];
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;

    final logData = <String, dynamic>{
      'url': options.uri.toString(),
      'method': options.method,
      'headers': Map<String, dynamic>.from(options.headers),
    };
    if (options.queryParameters.isNotEmpty) {
      logData['queryParameters'] = options.queryParameters;
    }
    if (options.data != null) {
      logData['data'] = options.data;
    }

    if (kDebugMode) {
      debugPrint('\u2550' * 38);
      debugPrint('[HTTP REQUEST] ' + options.method + ' ' + options.uri.toString());
      debugPrint('\u2550' * 38);
      debugPrint('[Request Body]');
      debugPrint(_safeEncode(options.data));
      debugPrint('');
    }

    AppLogger.debug(
      '[HTTP] ' + options.method + ' ' + options.uri.path,
      module: 'network',
      data: logData,
    );
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra[_startTimeKey] as int?;
    final traceId = response.requestOptions.extra[_traceIdHeader] as String?;
    final elapsed = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : null;
    final uri = response.requestOptions.uri;

    if (kDebugMode) {
      debugPrint('\u2550' * 38);
      debugPrint('[HTTP RESPONSE] ' + response.statusCode.toString() + ' ' + uri.path + ' (' + (elapsed?.toString() ?? '?') + 'ms)');
      debugPrint('\u2550' * 38);
      debugPrint('[Response Body]');
      debugPrint(_safeEncode(response.data));
      debugPrint('');
    }

    AppLogger.info(
      '[HTTP] ' + response.statusCode.toString() + ' ' + uri.path + ' (' + (elapsed?.toString() ?? '?') + 'ms)',
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
    final uri = err.requestOptions.uri;

    if (kDebugMode) {
      debugPrint('\u2550' * 38);
      debugPrint('[HTTP ERROR] ' + err.type.toString() + ' ' + (err.response?.statusCode?.toString() ?? '?') + ' ' + uri.path + ' (' + (elapsed?.toString() ?? '?') + 'ms)');
      debugPrint('\u2550' * 38);
      if (err.response?.data != null) {
        debugPrint('[Error Response Body]');
        debugPrint(_safeEncode(err.response!.data));
        debugPrint('');
      }
    }

    AppLogger.error(
      '[HTTP] ' + err.type.toString() + ' ' + (err.response?.statusCode?.toString() ?? '?') + ' ' + uri.path + ' (' + (elapsed?.toString() ?? '?') + 'ms)',
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
