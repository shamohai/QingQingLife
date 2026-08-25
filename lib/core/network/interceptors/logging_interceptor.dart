import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../app/config/env.dart';

/// 请求/响应日志拦截器，仅在 dev 环境生效
class LoggingInterceptor extends Interceptor {
  static final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 0),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);
    if (!EnvConfig.isDev) return handler.next(options);
    _logger.i('[REQ] ${options.method} ${options.uri}');
    if (options.data != null) _logger.i('  body: ${options.data}');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    if (!EnvConfig.isDev) return handler.next(response);
    _logger.i('[RES] ${response.statusCode} ${response.requestOptions.uri}');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
    if (!EnvConfig.isDev) return handler.next(err);
    _logger.e('[ERR] ${err.type} ${err.response?.statusCode} ${err.message}');
    return handler.next(err);
  }
}