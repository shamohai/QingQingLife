import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/session_provider.dart';

enum AuthStatus { initial, loading, authenticated, wechatAuthenticated, unauthenticated }

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(() => AuthNotifier());

class AuthNotifier extends Notifier<AuthStatus> {
  fluwx.FluwxCancelable? _authSubscriber;

  @override
  AuthStatus build() => AuthStatus.initial;

  AuthRepository get _repository => ref.read(authRepositoryProvider);
  SessionNotifier get _session => ref.read(sessionProvider.notifier);

  Future<void> wechatLogin() async {
    debugPrint('[Auth][WeChat] login started');
    state = AuthStatus.loading;
    _authSubscriber?.cancel();
    _authSubscriber = fluwx.Fluwx().addSubscriber(_handleWeChatResponse);
    debugPrint('[Auth][WeChat] response subscriber registered');
    try {
      final isInstalled = await fluwx.Fluwx().isWeChatInstalled;
      debugPrint('[Auth][WeChat] installed=$isInstalled');
      final success = await fluwx.Fluwx().authBy(
        which: fluwx.NormalAuth(scope: 'snsapi_userinfo', state: 'wechat_login'),
      );
      debugPrint('[Auth][WeChat] authBy returned=$success');
      if (!success) {
        debugPrint('[Auth][WeChat] authBy rejected by native SDK');
        state = AuthStatus.unauthenticated;
      }
    } catch (e, stackTrace) {
      debugPrint('[Auth][WeChat] login exception: $e\n$stackTrace');
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> _handleWeChatResponse(fluwx.WeChatResponse response) async {
    debugPrint('[Auth][WeChat] response received: ${response.runtimeType}, errCode=${response.errCode}');
    if (response is fluwx.WeChatAuthResponse) {
      _authSubscriber?.cancel();
      _authSubscriber = null;
      if (response.isSuccessful && response.code != null && response.code!.isNotEmpty) {
        debugPrint('[Auth][WeChat] auth code received');
        try {
          await _doWeChatLogin(response.code!);
        } catch (e, stackTrace) {
          debugPrint('[Auth][WeChat] exchange code exception: $e\n$stackTrace');
          state = AuthStatus.unauthenticated;
        }
      } else {
        debugPrint('[Auth][WeChat] cancelled or failed, errCode=${response.errCode}');
        state = AuthStatus.unauthenticated;
      }
    }
  }

  Future<void> _doWeChatLogin(String code) async {
    final response = await _repository.loginWithWeChatCode(code: code);
    if (response.success) {
      final result = response.data!;
      await _session.login(result.accessToken, refreshToken: result.refreshToken);
      state = AuthStatus.authenticated;
    } else if (response.code == 295) {
      await _session.savePendingWechatCode(code);
      state = AuthStatus.wechatAuthenticated;
    } else {
      debugPrint('[Auth][WeChat] server rejected login: code=${response.code} msg=${response.message}');
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> phoneLogin({required String phone, required String code}) async {
    state = AuthStatus.loading;
    final response = await _repository.loginWithPhone(phone: phone, code: code);
    if (response.success) {
      final result = response.data!;
      await _session.login(result.accessToken, refreshToken: result.refreshToken);
      state = AuthStatus.authenticated;
    } else {
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> phoneBind({required String phone, required String code}) async {
    state = AuthStatus.loading;
    final wechatCode = await _session.readPendingWechatCode();
    final response = await _repository.phoneBind(phone: phone, code: code, wechatCode: wechatCode ?? '');
    if (response.success) {
      final result = response.data!;
      await _session.login(result.accessToken, refreshToken: result.refreshToken);
      await _session.clearPendingWechatCode();
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
    await _session.logout();
    state = AuthStatus.unauthenticated;
  }

  Future<ApiResponse<UserInfo>> getCurrentUser() async => _repository.getCurrentUser();
  Future<ApiResponse<String>> refreshToken() async => _repository.refreshToken();
  Future<bool> isLoggedIn() async => _repository.isLoggedIn();
}
