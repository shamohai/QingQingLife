import 'package:dio/dio.dart';

import '../exceptions/exceptions.dart';

/// 统一错误处理拦截器，将 DioException 转换为业务异常
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioError(err);
    handler.next(err.copyWith(error: exception));
  }

  NetworkException _mapDioError(DioException err) {
    final statusCode = err.response?.statusCode;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ConnectionException(message: '网络连接异常，请检查网络设置');
      case DioExceptionType.badResponse:
        if (statusCode == 401) {
          return const AuthException(message: '登录已过期，请重新登录');
        }
        return HttpException(message: _extractServerMessage(err.response?.data) ?? 'HTTP $statusCode 错误', statusCode: statusCode);
      case DioExceptionType.cancel:
        return const NetworkException(message: '请求已取消');
      default:
        return NetworkException(message: err.message ?? '未知网络错误');
    }
  }

  /// 安全提取服务端错误信息。
  ///
  /// 错误响应体可能是 JSON Map、纯文本（String）、HTML 或其他类型，
  /// 只有 Map 且 message 为非空字符串时才返回，避免对非 Map 做下标访问导致异常。
  String? _extractServerMessage(dynamic data) {
    if (data is! Map) return null;
    final message = data['message'];
    if (message is! String || message.trim().isEmpty) return null;
    return message;
  }
}
