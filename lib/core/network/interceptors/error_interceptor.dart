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
        return HttpException(
          message: err.response?.data?['message'] ?? 'HTTP $statusCode 错误',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException(message: '请求已取消');
      default:
        return NetworkException(message: err.message ?? '未知网络错误');
    }
  }
}