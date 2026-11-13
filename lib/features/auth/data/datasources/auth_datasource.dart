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
  Future<ApiResponse<AuthResult>> loginWithPhone({required String phone, required String code}) async {
    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      return ApiResponse.error('验证码格式错误');
    }
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
  Future<ApiResponse<AuthResult>> phoneBind({required String phone, required String code, required String wechatCode}) async {
    if (!RegExp(r'^1\d{10}$').hasMatch(phone)) {
      return ApiResponse.error('请输入正确的手机号');
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return ApiResponse.error('验证码需为 6 位数字');
    }
    if (wechatCode.isEmpty) {
      return ApiResponse.error('微信授权已失效，请重新登录');
    }

    final client = _apiClient;
    if (client == null) {
      return ApiResponse.error('登录服务暂不可用');
    }

    return await client.post(
      '/api/sys/app/login',
      data: {'code': wechatCode, 'mobile': phone, 'smscode': code},
      fromJson: (dynamic json) => AuthResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> sendSmsCode({required String phone, required SmsType smsType}) async {
    if (!RegExp(r'^1\d{10}$').hasMatch(phone)) {
      return ApiResponse.error('请输入正确的手机号');
    }
    return _apiClient!.post<void>('/api/common/sendsms', data: {'mobile': phone, 'smstype': smsType.value, 'content': null});
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
  Future<ApiResponse<UserInfo>> getCurrentUser() async {
    final token = await _storage.readAuthToken();
    if (token == null || token.isEmpty) {
      return ApiResponse.error('未登录', code: 401);
    }
    return _apiClient!.post<UserInfo>('/api/sys/app/getmyprofile', fromJson: (dynamic json) => UserInfo.fromJson(json as Map<String, dynamic>));
  }

  @override
  Future<ApiResponse<String>> refreshToken() async {
    final oldToken = await _storage.readAuthToken();
    if (oldToken == null || oldToken.isEmpty) {
      return ApiResponse.error('Token 为空', code: 401);
    }
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
