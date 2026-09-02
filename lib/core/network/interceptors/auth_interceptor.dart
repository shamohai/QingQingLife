import 'package:dio/dio.dart';

import '../../storage/secure_storage.dart';

/// Token 注入拦截器
/// 
/// 将 authtoken 注入请求 body 的 meta.authtoken 字段中。
/// 
/// 注意：真实的 authtoken 注入由 [EncryptInterceptor] 完成，
/// 此拦截器仅负责在 URL 层面保留原有的 Authorization header（如有需要）。
/// 
/// 本项目的认证流程：
/// 1. EncryptInterceptor 将 token 写入请求 body 的 authtoken 字段
/// 2. 服务端从 body 中读取 authtoken 进行身份校验
class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;

  const AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      // 将 token 存入 extra，供 EncryptInterceptor 读取并写入 body
      options.extra['authtoken'] = token;
    }
    return handler.next(options);
  }
}
