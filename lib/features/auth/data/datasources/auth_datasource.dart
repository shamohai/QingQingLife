import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../../../core/storage/secure_storage.dart';

/// 统一认证数据源（实现 AuthRepository 接口）
///
/// 处理微信登录、手机号快捷登录、验证码发送、绑定及账号登出能力。
class AuthDataSource implements AuthRepository {
  final ApiClient? _apiClient;
  final SecureStorage _storage = SecureStorage();

  AuthDataSource({this._apiClient});

  @override
  Future<ApiResponse<AuthResult>> loginWithPhone({required String phone, required String code}) {
    return _apiClient!.post<AuthResult>(
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
  Future<ApiResponse<AuthResult>> loginWithWeChatCode({required String code}) {
    return _apiClient!.post<AuthResult>(
      '/api/sys/app/login',
      data: {'code': code},
      fromJson: (dynamic json) => AuthResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<AuthResult>> phoneBind({required String phone, required String code, required String wechatCode}) {
    return _apiClient!.post<AuthResult>(
      '/api/sys/user/bindPhone',
      data: {'phone': phone, 'code': code, 'wechatCode': wechatCode},
      fromJson: (dynamic json) => AuthResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> sendSmsCode({required String phone}) {
    return _apiClient!.post<void>('/api/sys/user/sendCode', data: {'phone': phone});
  }

  @override
  Future<ApiResponse<void>> logout() {
    return _apiClient!.post<void>('/api/sys/logout');
  }

  @override
  Future<ApiResponse<void>> deleteAccount() {
    return _apiClient!.post<void>('/api/sys/deluser');
  }

  @override
  Future<ApiResponse<UserInfo>> getCurrentUser() {
    return _apiClient!.post<UserInfo>('/api/sys/app/getmyprofile', fromJson: (dynamic json) => UserInfo.fromJson(json as Map<String, dynamic>));
  }

  @override
  Future<ApiResponse<String>> refreshToken() {
    return _apiClient!.post<String>('/api/sys/user/refreshToken', fromJson: (dynamic json) => (json as dynamic) as String);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.readAuthToken();
    return token != null && token.isNotEmpty;
  }
}

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSource(apiClient: ref.read(apiClientProvider));
});
