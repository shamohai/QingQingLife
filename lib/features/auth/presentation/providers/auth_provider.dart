import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/config/app_config.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/storage/local_storage.dart';

class UserInfo {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final int points;
  final int memberLevel;
  const UserInfo({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    this.points = 0,
    this.memberLevel = 1,
  });
}

enum AuthStatus { initial, loading, authenticated, unauthenticated }

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  () => AuthNotifier(),
);

class AuthNotifier extends Notifier<AuthStatus> {
  final SecureStorage _storage = SecureStorage();
  final LocalStorage _localStorage = LocalStorage();
  fluwx.FluwxCancelable? _authSubscriber;

  @override
  AuthStatus build() => AuthStatus.initial;

  Future<void> _completeLogin() async {
    final mockAccessToken = const Uuid().v4();
    await _storage.writeAccessToken(mockAccessToken);
    await _localStorage.putString('access_token', mockAccessToken);
    await _localStorage.putString('nickname', '青轻用户');
    await _localStorage.putBool('is_login', true);
    state = AuthStatus.authenticated;
  }

  Future<void> wechatLogin() async {
    state = AuthStatus.loading;
    await fluwx.Fluwx().registerApi(appId: AppConfig.wechatAppId);
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
        await _mockLogin();
        return;
      }
    } catch (e) {
      debugPrint('[Auth] wechatLogin exception: ');
      await _mockLogin();
    }
  }

  void _handleWeChatResponse(fluwx.WeChatResponse response) {
    if (response is fluwx.WeChatAuthResponse) {
      _authSubscriber?.cancel();
      _authSubscriber = null;
      if (response.isSuccessful && response.code != null) {
        debugPrint('[Auth] WeChat auth code received');
        _completeLogin();
      } else {
        debugPrint('[Auth] WeChat auth cancelled');
        state = AuthStatus.unauthenticated;
      }
    }
  }

  Future<void> phoneLogin({required String phone, required String code}) async {
    state = AuthStatus.loading;
    await _mockLogin();
  }

  Future<void> logout() async {
    state = AuthStatus.loading;
    _authSubscriber?.cancel();
    _authSubscriber = null;
    await _storage.clearTokens();
    await _localStorage.remove('is_login');
    state = AuthStatus.unauthenticated;
  }

  Future<void> _mockLogin() async {
    await Future.delayed(const Duration(seconds: 1));
    final accessToken = const Uuid().v4();
    await _storage.writeAccessToken(accessToken);
    await _localStorage.putString('access_token', accessToken);
    await _localStorage.putString('nickname', '青轻用户');
    await _localStorage.putBool('is_login', true);
    state = AuthStatus.authenticated;
  }

  UserInfo get currentUser => const UserInfo(
    id: 'u001',
    nickname: '青轻用户_9527',
    points: 3580,
    memberLevel: 2,
  );
}
