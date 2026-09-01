import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/providers/repository_providers.dart';

enum AuthStatus { initial, loading, authenticated, wechatAuthenticated, unauthenticated }

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  () => AuthNotifier(),
);

class AuthNotifier extends Notifier<AuthStatus> {

  fluwx.FluwxCancelable? _authSubscriber;

  @override
  AuthStatus build() => AuthStatus.initial;

  AuthRepository get _repository => ref.read(authRepositoryProvider);

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
      if (!success) {
        debugPrint('[Auth] wechat authBy failed');
        await _mockLoginFallback();
      }
    } catch (e) {
      debugPrint('[Auth] wechatLogin exception: $e');
      await _mockLoginFallback();
    }
  }

  Future<void> _handleWeChatResponse(fluwx.WeChatResponse response) async {
    if (response is fluwx.WeChatAuthResponse) {
      _authSubscriber?.cancel();
      _authSubscriber = null;
      if (response.isSuccessful && response.code != null) {
        debugPrint('[Auth] WeChat auth code received');
        await _mockLoginFallback();
      } else {
        debugPrint('[Auth] WeChat auth cancelled');
        state = AuthStatus.unauthenticated;
      }
    }
  }

  Future<void> phoneLogin({required String phone, required String code}) async {
    state = AuthStatus.loading;
    final response = await _repository.loginWithPhone(phone: phone, code: code);
    if (response.success) {
      state = AuthStatus.authenticated;
    } else {
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> phoneBind({required String phone, required String code}) async {
    state = AuthStatus.loading;
    final response = await _repository.loginWithPhone(phone: phone, code: code);
    if (response.success) {
      state = AuthStatus.authenticated;
    } else {
      state = AuthStatus.wechatAuthenticated;
    }
  }

  Future<void> logout() async {
    state = AuthStatus.loading;
    _authSubscriber?.cancel();
    _authSubscriber = null;
    await _repository.logout();
    state = AuthStatus.unauthenticated;
  }

  Future<void> _mockLoginFallback() async {
    final response = await _repository.loginWithPhone(phone: '13800000000', code: '123456');
    if (response.success) {
      state = AuthStatus.wechatAuthenticated;
    } else {
      state = AuthStatus.unauthenticated;
    }
  }

  Future<ApiResponse<UserInfo>> getCurrentUser() async {
    return _repository.getCurrentUser();
  }

  Future<ApiResponse<String>> refreshToken() async {
    return _repository.refreshToken();
  }

  Future<bool> isLoggedIn() async {
    return _repository.isLoggedIn();
  }
}
