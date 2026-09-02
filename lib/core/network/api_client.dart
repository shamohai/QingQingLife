import 'package:dio/dio.dart';
import 'api_response.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import '../../core/logging/interceptors/app_logging_interceptor.dart';
import '../../app/config/app_config.dart';
import '../storage/secure_storage.dart';

/// 统一网络请求入口类
/// 
/// 基于 Dio 封装，集成了日志、认证和错误处理拦截器。
/// 所有的业务 DataSource 都应该通过此类发起网络请求。
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
    // 注入拦截器流水线
    dio.interceptors.addAll([
      AppLoggingInterceptor(), // 请求/响应日志记录
      AuthInterceptor(_storage), // 自动注入 Token 和处理 401 无感刷新
      ErrorInterceptor(), // 业务异常统一解析与转换
    ]);
  }

  /// 发起 GET 请求
  /// [path]: 请求路径
  /// [fromJson]: 可选的解析函数，用于将响应数据转换为业务模型
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await dio.get(path, queryParameters: queryParameters);
    return _parse<T>(response, fromJson);
  }

  /// 发起 POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await dio.post(path, data: data, queryParameters: queryParameters);
    return _parse<T>(response, fromJson);
  }

  /// 发起 PUT 请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await dio.put(path, data: data, queryParameters: queryParameters);
    return _parse<T>(response, fromJson);
  }

  /// 发起 DELETE 请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await dio.delete(path, queryParameters: queryParameters);
    return _parse<T>(response, fromJson);
  }

  /// 将 Dio 的 Response 对象解析为统一的业务 ApiResponse 模型
  ApiResponse<T> _parse<T>(Response<dynamic> response, T Function(dynamic)? fromJson) {
    final body = response.data as Map<String, dynamic>? ?? {};
    return ApiResponse.fromJson(body, fromJson);
  }
}
