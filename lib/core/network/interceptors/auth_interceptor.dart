import 'package:dio/dio.dart';
import '../../storage/secure_storage.dart';

/// Token 注入拦截器，将 accessToken 自动附加到 Authorization header
class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;

  const AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}