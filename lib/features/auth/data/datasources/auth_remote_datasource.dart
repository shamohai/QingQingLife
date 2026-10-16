import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../../../core/storage/secure_storage.dart';

/// 真实 API 认证数据源
///
/// 接口：POST /api/sys/app/login
/// 参数：{ "code": "微信授权临时码" }
/// 响应：
///   code == 0   → 用户已注册，返回 accessToken + userInfo
///   code == 295 → 用户未绑定手机号，需跳转绑定页
///
/// authtoken / devid 由 AuthInterceptor + EncryptInterceptor 从 SecureStorage
/// 自动注入到每个请求体，无需在数据源层手动传参。
class RemoteAuthDataSource implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _storage = SecureStorage();

  RemoteAuthDataSource({required this._apiClient});

  @override
  Future<ApiResponse<AuthResult>> loginWithPhone({required String phone, required String code}) async {
    return _apiClient.post(
      '/api/sys/user/login',
      data: {'phone': phone, 'code': code},
      fromJson: (dynamic json) => AuthResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<AuthResult>> loginWithWeChat() async {
    return loginWithWeChatCode(code: '');
  }

  @override
  Future<ApiResponse<AuthResult>> loginWithWeChatCode({required String code}) async {
    return _apiClient.post('/api/sys/app/login', data: {'code': code}, fromJson: (dynamic json) => AuthResult.fromJson(json as Map<String, dynamic>));
  }

  @override
  Future<ApiResponse<AuthResult>> phoneBind({required String phone, required String code, required String wechatCode}) async {
    return _apiClient.post('/api/sys/user/bindPhone', data: {'phone': phone, 'code': code, 'wechatCode': wechatCode});
  }

  @override
  Future<ApiResponse<void>> sendSmsCode({required String phone}) async {
    return _apiClient.post('/api/sys/user/sendCode', data: {'phone': phone});
  }

  @override
  Future<ApiResponse<void>> logout() async {
    // POST /api/sys/logout — authtoken 由拦截器自动注入
    return _apiClient.post<void>('/api/sys/logout');
  }

  @override
  Future<ApiResponse<void>> deleteAccount() async {
    // POST /api/sys/deluser — authtoken 由拦截器自动注入；操作不可逆
    return _apiClient.post<void>('/api/sys/deluser');
  }

  @override
  Future<ApiResponse<UserInfo>> getCurrentUser() async {
    // POST /api/sys/app/getmyprofile — authtoken 由 AuthInterceptor 自动注入
    return _apiClient.post('/api/sys/app/getmyprofile', fromJson: (dynamic json) => UserInfo.fromJson(json as Map<String, dynamic>));
  }

  @override
  Future<ApiResponse<String>> refreshToken() async {
    return _apiClient.post('/api/sys/user/refreshToken', fromJson: (dynamic json) => (json as dynamic) as String);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.readAuthToken() ?? await _storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }
}

final remoteAuthDataSourceProvider = Provider<RemoteAuthDataSource>((ref) {
  return RemoteAuthDataSource(apiClient: ref.read(apiClientProvider));
});
