import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/storage/local_storage.dart';

/// Mock 认证数据源 - 开发/测试环境使用
/// 真实 API 就绪后，替换为 RemoteAuthDataSource
class MockAuthDataSource implements AuthRepository {
  final SecureStorage _storage = SecureStorage();
  final LocalStorage _localStorage = LocalStorage();
  final _uuid = const Uuid();

  // 模拟用户数据
  static const _mockUser = UserInfo(
    id: 'u001',
    nickname: '青轻用户_9527',
    avatarUrl: null,
    points: 3580,
    memberLevel: 2,
    phone: '138****1234',
  );

  @override
  Future<ApiResponse<AuthResult>> loginWithPhone({required String phone, required String code}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 简单校验：验证码为 6 位数字
    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      return ApiResponse.error('验证码格式错误');
    }

    final accessToken = _uuid.v4();
    final refreshToken = _uuid.v4();

    await _storage.writeAccessToken(accessToken);
    await _storage.writeRefreshToken(refreshToken);
    await _localStorage.putString('access_token', accessToken);
    await _localStorage.putString('refresh_token', refreshToken);
    await _localStorage.putString('nickname', _mockUser.nickname);
    await _localStorage.putBool('is_login', true);

    return ApiResponse.success(AuthResult(accessToken: accessToken, refreshToken: refreshToken, userInfo: _mockUser));
  }

  @override
  Future<ApiResponse<AuthResult>> loginWithWeChat() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final accessToken = _uuid.v4();
    final refreshToken = _uuid.v4();

    await _storage.writeAccessToken(accessToken);
    await _storage.writeRefreshToken(refreshToken);
    await _localStorage.putString('access_token', accessToken);
    await _localStorage.putString('refresh_token', refreshToken);
    await _localStorage.putString('nickname', _mockUser.nickname);
    await _localStorage.putBool('is_login', true);

    return ApiResponse.success(AuthResult(accessToken: accessToken, refreshToken: refreshToken, userInfo: _mockUser));
  }

  @override
  Future<ApiResponse<AuthResult>> loginWithWeChatCode({required String code}) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final accessToken = _uuid.v4();
    final refreshToken = _uuid.v4();
    await _storage.writeAccessToken(accessToken);
    await _storage.writeRefreshToken(refreshToken);
    await _localStorage.putString('access_token', accessToken);
    await _localStorage.putString('refresh_token', refreshToken);
    await _localStorage.putString('nickname', _mockUser.nickname);
    await _localStorage.putBool('is_login', true);
    return ApiResponse.success(AuthResult(accessToken: accessToken, refreshToken: refreshToken, userInfo: _mockUser));
  }

  @override
  Future<ApiResponse<AuthResult>> phoneBind({required String phone, required String code, required String wechatCode}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final accessToken = _uuid.v4();
    final refreshToken = _uuid.v4();
    await _storage.writeAccessToken(accessToken);
    await _storage.writeRefreshToken(refreshToken);
    await _localStorage.putString('access_token', accessToken);
    await _localStorage.putString('refresh_token', refreshToken);
    await _localStorage.putBool('is_login', true);
    return ApiResponse.success(AuthResult(accessToken: accessToken, refreshToken: refreshToken, userInfo: _mockUser));
  }

  @override
  Future<ApiResponse<void>> sendSmsCode({required String phone}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      return ApiResponse.error('手机号格式错误');
    }

    // 模拟发送成功（实际应返回验证码或标识）
    debugPrint('[MockAuth] 向 $phone 发送验证码: 123456');
    return ApiResponse.success(null);
  }

  @override
  Future<void> logout() async {
    await _storage.clearTokens();
    await _localStorage.remove('access_token');
    await _localStorage.remove('refresh_token');
    await _localStorage.remove('nickname');
    await _localStorage.remove('is_login');
  }

  @override
  Future<ApiResponse<UserInfo>> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final token = await _storage.readAccessToken();
    if (token == null || token.isEmpty) {
      return ApiResponse.error('未登录', code: 401);
    }

    return ApiResponse.success(_mockUser);
  }

  @override
  Future<ApiResponse<String>> refreshToken() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final oldToken = await _storage.readAccessToken();
    if (oldToken == null || oldToken.isEmpty) {
      return ApiResponse.error('Token 为空', code: 401);
    }

    final newToken = _uuid.v4();
    await _storage.writeAccessToken(newToken);
    await _localStorage.putString('access_token', newToken);

    return ApiResponse.success(newToken);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }
}

/// MockAuthRepository Provider - 开发环境使用
final mockAuthRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthDataSource());
