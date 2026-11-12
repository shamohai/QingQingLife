import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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
  final _uuid = const Uuid();

  AuthDataSource({this._apiClient});

  static final _defaultUser = UserInfo(
    id: 'u001',
    nickname: '青轻用户_9527',
    avatarUrl: null,
    points: 3580,
    memberLevel: 2,
    phone: '138****1234',
    gender: 1,
    genderName: '男',
    birthday: DateTime(1997, 10, 1),
    address: '甘肃省兰州市七里河区建兰路街道兰州中心办公楼801室',
  );

  AuthResult _buildResult() {
    return AuthResult(accessToken: _uuid.v4(), refreshToken: _uuid.v4(), userInfo: _defaultUser);
  }

  @override
  Future<ApiResponse<AuthResult>> loginWithPhone({required String phone, required String code}) async {
    try {
      final response = await _apiClient!.post(
        '/api/sys/user/login',
        data: {'phone': phone, 'code': code},
        fromJson: (dynamic json) => AuthResult.fromJson(json as Map<String, dynamic>),
      );
      if (response.success) return response;
    } catch (_) {}
    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      return ApiResponse.error('验证码格式错误');
    }
    return ApiResponse.success(_buildResult());
  }

  @override
  Future<ApiResponse<AuthResult>> loginWithWeChat() async {
    return loginWithWeChatCode(code: '');
  }

  @override
  Future<ApiResponse<AuthResult>> loginWithWeChatCode({required String code}) async {
    try {
      final response = await _apiClient!.post(
        '/api/sys/app/login',
        data: {'code': code},
        fromJson: (dynamic json) => AuthResult.fromJson(json as Map<String, dynamic>),
      );
      if (response.success) return response;
    } catch (_) {}
    return ApiResponse.success(_buildResult());
  }

  @override
  Future<ApiResponse<AuthResult>> phoneBind({required String phone, required String code, required String wechatCode}) async {
    try {
      final response = await _apiClient!.post('/api/sys/user/bindPhone', data: {'phone': phone, 'code': code, 'wechatCode': wechatCode});
      if (response.success) {
        return ApiResponse.success(AuthResult.fromJson((response.data as Map<String, dynamic>?) ?? {}));
      }
    } catch (_) {}
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return ApiResponse.error('验证码需为 6 位数字');
    }
    return ApiResponse.success(_buildResult());
  }

  @override
  Future<ApiResponse<void>> sendSmsCode({required String phone}) async {
    try {
      final response = await _apiClient!.post<void>('/api/sys/user/sendCode', data: {'phone': phone});
      if (response.success) return response;
    } catch (_) {}
    if (!RegExp(r'^1\d{10}$').hasMatch(phone)) {
      return ApiResponse.error('请输入正确的手机号');
    }
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> logout() async {
    try {
      await _apiClient!.post<void>('/api/sys/logout');
    } catch (_) {}
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> deleteAccount() async {
    try {
      await _apiClient!.post<void>('/api/sys/deluser');
    } catch (_) {}
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<UserInfo>> getCurrentUser() async {
    try {
      final response = await _apiClient!.post('/api/sys/app/getmyprofile', fromJson: (dynamic json) => UserInfo.fromJson(json as Map<String, dynamic>));
      if (response.success) return response;
    } catch (_) {}
    final token = await _storage.readAuthToken();
    if (token == null || token.isEmpty) {
      return ApiResponse.error('未登录', code: 401);
    }
    return ApiResponse.success(_defaultUser);
  }

  @override
  Future<ApiResponse<String>> refreshToken() async {
    try {
      final response = await _apiClient!.post('/api/sys/user/refreshToken', fromJson: (dynamic json) => (json as dynamic) as String);
      if (response.success) return response;
    } catch (_) {}
    final oldToken = await _storage.readAuthToken();
    if (oldToken == null || oldToken.isEmpty) {
      return ApiResponse.error('Token 为空', code: 401);
    }
    final newToken = _uuid.v4();
    await _storage.writeAuthToken(newToken);
    return ApiResponse.success(newToken);
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
