import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/storage/secure_storage.dart';

/// Mock 认证数据源 - 开发/测试环境使用
/// 真实 API 就绪后，替换为 RemoteAuthDataSource
///
/// 登录结果只返回给调用方，由 [SessionNotifier.login] 统一写入本地登录状态；
/// 本层不再重复落库，避免同一凭证被写进多份存储。
class MockAuthDataSource implements AuthRepository {
  final SecureStorage _storage = SecureStorage();
  final _uuid = const Uuid();

  // 模拟用户数据
  static final _mockUser = UserInfo(
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

  /// 生成一次模拟登录结果（不写存储）
  AuthResult _buildResult() {
    return AuthResult(accessToken: _uuid.v4(), refreshToken: _uuid.v4(), userInfo: _mockUser);
  }

  @override
  Future<ApiResponse<AuthResult>> loginWithPhone({required String phone, required String code}) async {
    // 简单校验：验证码为 6 位数字
    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      return ApiResponse.error('验证码格式错误');
    }
    return ApiResponse.success(_buildResult());
  }

  @override
  Future<ApiResponse<AuthResult>> loginWithWeChat() async => ApiResponse.success(_buildResult());

  @override
  Future<ApiResponse<AuthResult>> loginWithWeChatCode({required String code}) async => ApiResponse.success(_buildResult());

  @override
  Future<ApiResponse<AuthResult>> phoneBind({required String phone, required String code, required String wechatCode}) async {
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return ApiResponse.error('验证码需为 6 位数字');
    }
    return ApiResponse.success(_buildResult());
  }

  @override
  Future<ApiResponse<void>> sendSmsCode({required String phone}) async {
    if (!RegExp(r'^1\d{10}$').hasMatch(phone)) {
      return ApiResponse.error('请输入正确的手机号');
    }

    // 模拟发送成功（实际应返回验证码或标识）
    debugPrint('[MockAuth] 向 $phone 发送验证码: 123456');
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> deleteAccount() async {
    // Mock：本地登录状态由 SessionNotifier 统一清理
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> logout() async {
    // Mock：本地登录状态由 SessionNotifier 统一清理
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<UserInfo>> getCurrentUser() async {
    final token = await _storage.readAuthToken();
    if (token == null || token.isEmpty) {
      return ApiResponse.error('未登录', code: 401);
    }
    return ApiResponse.success(_mockUser);
  }

  /// 刷新令牌：无 SessionNotifier 包装的调用方依赖本方法写回新令牌。
  @override
  Future<ApiResponse<String>> refreshToken() async {
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

/// MockAuthRepository Provider - 开发环境使用
final mockAuthRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthDataSource());
