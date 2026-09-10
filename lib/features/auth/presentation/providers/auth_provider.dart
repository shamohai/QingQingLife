import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/logging/app_logger.dart';
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
    AppLogger.info('WeChat login started', module: 'wechat', event: 'login_start');
    state = AuthStatus.loading;
    _authSubscriber?.cancel();
    _authSubscriber = fluwx.Fluwx().addSubscriber(_handleWeChatResponse);
    AppLogger.info('Response subscriber registered', module: 'wechat', event: 'subscriber_registered');
    try {
      final isInstalled = await fluwx.Fluwx().isWeChatInstalled;
      AppLogger.info('WeChat installed=$isInstalled', module: 'wechat', event: 'installed_check');
      final success = await fluwx.Fluwx().authBy(
        which: fluwx.NormalAuth(scope: 'snsapi_userinfo', state: 'wechat_login'),
      );
      AppLogger.info('authBy returned=$success', module: 'wechat', event: 'auth_request_result');
      // authBy 返回 false 说明已唤起微信 SDK（回调由 _handleWeChatResponse 处理）
      // 不要在这里重置 state，保持 loading 等待回调
      if (!success) {
        AppLogger.warning('authBy rejected by native SDK', module: 'wechat', event: 'auth_request_rejected');
      }
    } catch (e, stackTrace) {
      AppLogger.error('WeChat login exception', module: 'wechat', event: 'login_error', error: e, stackTrace: stackTrace);
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> _handleWeChatResponse(fluwx.WeChatResponse response) async {
    AppLogger.info('Response received: ${response.runtimeType}, errCode=${response.errCode}', module: 'wechat', event: 'response_received');
    if (response is fluwx.WeChatAuthResponse) {
      _authSubscriber?.cancel();
      _authSubscriber = null;
      if (response.isSuccessful && response.code != null && response.code!.isNotEmpty) {
        AppLogger.info('Auth code received', module: 'wechat', event: 'auth_code_received');
        try {
          await _doWeChatLogin(response.code!);
        } catch (e, stackTrace) {
          AppLogger.error('Exchange code exception', module: 'wechat', event: 'exchange_error', error: e, stackTrace: stackTrace);
          state = AuthStatus.unauthenticated;
        }
      } else {
        AppLogger.warning('Cancelled or failed, errCode=${response.errCode}', module: 'wechat', event: 'auth_cancelled');
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
      AppLogger.warning('Server rejected login: code=${response.code} msg=${response.message}', module: 'wechat', event: 'server_rejected');
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

  Future<bool> sendSmsCode({required String phone}) async {
    final response = await _repository.sendSmsCode(phone: phone);
    if (!response.success) {
      AppLogger.warning('SMS code request failed', module: 'auth', event: 'send_sms_failed', data: {'code': response.code, 'message': response.message});

    }
    return response.success;
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
