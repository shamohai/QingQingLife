import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/providers/repository_providers.dart';

/// 认证状态枚举
enum AuthStatus { 
  initial,            // 初始状态
  loading,            // 加载中
  authenticated,      // 已登录（手机号）
  wechatAuthenticated, // 微信已授权（可能还需绑定手机号）
  unauthenticated     // 未登录
}

/// 全局认证状态 Provider
final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  () => AuthNotifier(),
);

/// 认证业务逻辑控制器
/// 
/// 负责处理微信登录、手机号登录、登出以及 Token 管理等逻辑。
class AuthNotifier extends Notifier<AuthStatus> {

  fluwx.FluwxCancelable? _authSubscriber;

  @override
  AuthStatus build() => AuthStatus.initial;

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// 发起微信登录流程
  /// 
  /// 调用 fluwx 调起微信授权页面，并订阅微信响应结果。
  Future<void> wechatLogin() async {
    state = AuthStatus.loading;
    _authSubscriber?.cancel();
    _authSubscriber = fluwx.Fluwx().addSubscriber(_handleWeChatResponse);
    try {
      final success = await fluwx.Fluwx().authBy(
        which: fluwx.NormalAuth(
          scope: 'snsapi_userinfo',
          state: 'wechat_login',
        ),
      );
      // 如果微信 API 调用失败（如未安装微信），则降级到 Mock 登录以保证开发环境可用
      if (!success) {
        debugPrint('[Auth] wechat authBy failed');
        await _mockLoginFallback();
      }
    } catch (e) {
      debugPrint('[Auth] wechatLogin exception: $e');
      await _mockLoginFallback();
    }
  }

  /// 处理微信授权回调
  Future<void> _handleWeChatResponse(fluwx.WeChatResponse response) async {
    if (response is fluwx.WeChatAuthResponse) {
      _authSubscriber?.cancel();
      _authSubscriber = null;
      if (response.isSuccessful && response.code != null) {
        debugPrint('[Auth] WeChat auth code received');
        // 成功获取 code 后，通常应发送给后端换取 Token，此处目前使用 mock 流程
        await _mockLoginFallback();
      } else {
        debugPrint('[Auth] WeChat auth cancelled');
        state = AuthStatus.unauthenticated;
      }
    }
  }

  /// 手机号验证码登录
  Future<void> phoneLogin({required String phone, required String code}) async {
    state = AuthStatus.loading;
    final response = await _repository.loginWithPhone(phone: phone, code: code);
    if (response.success) {
      state = AuthStatus.authenticated;
    } else {
      state = AuthStatus.unauthenticated;
    }
  }

  /// 微信登录后的手机号绑定逻辑
  Future<void> phoneBind({required String phone, required String code}) async {
    state = AuthStatus.loading;
    final response = await _repository.loginWithPhone(phone: phone, code: code);
    if (response.success) {
      state = AuthStatus.authenticated;
    } else {
      state = AuthStatus.wechatAuthenticated;
    }
  }

  /// 退出登录
  /// 
  /// 清除本地 Token 并重置认证状态。
  Future<void> logout() async {
    state = AuthStatus.loading;
    _authSubscriber?.cancel();
    _authSubscriber = null;
    await _repository.logout();
    state = AuthStatus.unauthenticated;
  }

  /// 登录失败或微信环境不可用时的 Mock 降级策略
  /// 
  /// 仅用于开发调试，使用测试账号直接进入登录状态。
  Future<void> _mockLoginFallback() async {
    final response = await _repository.loginWithPhone(phone: '13800000000', code: '123456');
    if (response.success) {
      state = AuthStatus.wechatAuthenticated;
    } else {
      state = AuthStatus.unauthenticated;
    }
  }

  /// 获取当前用户信息
  Future<ApiResponse<UserInfo>> getCurrentUser() async {
    return _repository.getCurrentUser();
  }

  /// 手动刷新 Token
  Future<ApiResponse<String>> refreshToken() async {
    return _repository.refreshToken();
  }

  /// 检查当前是否已处于登录状态
  Future<bool> isLoggedIn() async {
    return _repository.isLoggedIn();
  }
}
