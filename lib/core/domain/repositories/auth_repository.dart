import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/api_response.dart';

/// 认证仓库接口
abstract class AuthRepository {
  /// 手机号验证码登录
  Future<ApiResponse<AuthResult>> loginWithPhone({required String phone, required String code});

  /// 微信登录
  Future<ApiResponse<AuthResult>> loginWithWeChat();

  /// 发送验证码
  Future<ApiResponse<void>> sendSmsCode({required String phone});

  /// 登出
  Future<void> logout();

  /// 获取当前用户信息
  Future<ApiResponse<UserInfo>> getCurrentUser();

  /// 刷新 Token
  Future<ApiResponse<String>> refreshToken();

  /// 检查登录态
  Future<bool> isLoggedIn();
}

/// 登录结果
class AuthResult {
  final String accessToken;
  final String? refreshToken;
  final UserInfo userInfo;

  const AuthResult({required this.accessToken, this.refreshToken, required this.userInfo});
}

/// 用户信息实体
class UserInfo {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final int points;
  final int memberLevel;
  final String? phone;

  const UserInfo({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    this.points = 0,
    this.memberLevel = 1,
    this.phone,
  });
}
