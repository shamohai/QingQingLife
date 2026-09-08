import 'package:dio/dio.dart';

import '../../app/config/app_config.dart';
import '../storage/secure_storage.dart';
import 'api_response.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/encrypt_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import '../logging/interceptors/app_logging_interceptor.dart';

/// 统一网络请求入口类
///
/// 基于 Dio 封装，集成加密签名、日志和错误处理拦截器。
///
/// 拦截器执行顺序：
/// 1. AppLoggingInterceptor  — 记录请求/响应日志
/// 2. AuthInterceptor        — 注入 authtoken 到 options.extra
/// 3. EncryptInterceptor     — 加密请求体、签名 URL、附加到请求
/// 4. ErrorInterceptor       — 统一处理 HTTP 和业务错误
class ApiClient {
  final Dio dio;
  final SecureStorage storage;

  ApiClient({required this.storage})
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: AppConfig.defaultConnectTimeout),
          receiveTimeout: const Duration(seconds: AppConfig.defaultReceiveTimeout),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        ),
      ) {
    // 注入拦截器流水线
    dio.interceptors.addAll([
      AppLoggingInterceptor(), // 请求/响应日志记录
      AuthInterceptor(storage), // 自动注入 Token 到 extra
      EncryptInterceptor(), // 请求加密 + MD5 签名
      ErrorInterceptor(), // 业务异常统一解析与转换
    ]);
  }

  /// 发起 GET 请求
  Future<ApiResponse<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, T Function(dynamic)? fromJson}) async {
    final response = await dio.get(path, queryParameters: queryParameters);
    return _parse<T>(response, fromJson);
  }

  /// 发起 POST 请求
  Future<ApiResponse<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, T Function(dynamic)? fromJson}) async {
    final response = await dio.post(path, data: data, queryParameters: queryParameters);
    return _parse<T>(response, fromJson);
  }

  /// 发起 PUT 请求
  Future<ApiResponse<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, T Function(dynamic)? fromJson}) async {
    final response = await dio.put(path, data: data, queryParameters: queryParameters);
    return _parse<T>(response, fromJson);
  }

  /// 发起 DELETE 请求
  Future<ApiResponse<T>> delete<T>(String path, {Map<String, dynamic>? queryParameters, T Function(dynamic)? fromJson}) async {
    final response = await dio.delete(path, queryParameters: queryParameters);
    return _parse<T>(response, fromJson);
  }

  /// 解析响应为标准 ApiResponse
  ApiResponse<T> _parse<T>(Response<dynamic> response, T Function(dynamic)? fromJson) {
    final body = response.data as Map<String, dynamic>? ?? {};
    return ApiResponse.fromJson(body, fromJson);
  }
}
