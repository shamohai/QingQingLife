import 'package:dio/dio.dart';
import 'api_response.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import '../../core/logging/interceptors/app_logging_interceptor.dart';
import '../../app/config/app_config.dart';
import '../storage/secure_storage.dart';

/// 统一网络请求入口
class ApiClient {
  final Dio dio;
  final SecureStorage _storage;

  ApiClient({required SecureStorage storage})
      : _storage = storage,
        dio = Dio(BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: AppConfig.defaultConnectTimeout),
          receiveTimeout: const Duration(seconds: AppConfig.defaultReceiveTimeout),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        )) {
    dio.interceptors.addAll([
      AppLoggingInterceptor(),
      AuthInterceptor(_storage),
      ErrorInterceptor(),
    ]);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await dio.get(path, queryParameters: queryParameters);
    return _parse<T>(response, fromJson);
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await dio.post(path, data: data, queryParameters: queryParameters);
    return _parse<T>(response, fromJson);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await dio.put(path, data: data, queryParameters: queryParameters);
    return _parse<T>(response, fromJson);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await dio.delete(path, queryParameters: queryParameters);
    return _parse<T>(response, fromJson);
  }

  ApiResponse<T> _parse<T>(Response<dynamic> response, T Function(dynamic)? fromJson) {
    final body = response.data as Map<String, dynamic>? ?? {};
    return ApiResponse.fromJson(body, fromJson);
  }
}