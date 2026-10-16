import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';

import '../../../../core/storage/secure_storage.dart';

/// 真实 API 认证数据源
///
/// 调用后端接口完成微信授权登录。
///
/// 接口：POST /api/sys/app/login
/// 参数：{ "code": "微信授权临时码" }
/// 响应：
///   code == 0   → 用户已注册，返回 accessToken + userInfo
///   code == 295 → 用户未绑定手机号，需跳转绑定页
class RemoteAuthDataSource implements AuthRepository {
  // 临时模拟“已登录”身份。首次读取用户信息时写入安全存储，后续统一从存储读取。
  static const _temporaryDeviceId = '17835616055244338';
  static const _temporaryAuthToken = '1575474';

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
  Future<void> logout() async {
    await _apiClient.post('/api/sys/user/logout');
  }

  @override
  Future<ApiResponse<UserInfo>> getCurrentUser() async {
    final identity = await _ensureTemporaryIdentity();
    return _apiClient.post(
      '/api/sys/app/getmyprofile',
      options: Options(extra: identity),
      fromJson: (dynamic json) => UserInfo.fromJson(json as Map<String, dynamic>),
    );
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

  /// 临时初始化联调身份；真实登录成功后，SessionNotifier 会覆盖这些值。
  Future<Map<String, String>> _ensureTemporaryIdentity() async {
    final deviceId = await _storage.readDeviceId() ?? _temporaryDeviceId;
    final authToken = await _storage.readAuthToken() ?? await _storage.readAccessToken() ?? _temporaryAuthToken;
    await _storage.writeDeviceId(deviceId);
    await _storage.writeAuthToken(authToken);
    await _storage.writeAccessToken(authToken);
    return <String, String>{'devid': deviceId, 'authtoken': authToken};
  }
}

final remoteAuthDataSourceProvider = Provider<RemoteAuthDataSource>((ref) {
  return RemoteAuthDataSource(apiClient: ref.read(apiClientProvider));
});
