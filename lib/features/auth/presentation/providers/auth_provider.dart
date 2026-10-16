import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../member/presentation/providers/user_profile_provider.dart';

enum AuthStatus { initial, loading, authenticated, wechatAuthenticated, unauthenticated }

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(() => AuthNotifier());

class AuthNotifier extends Notifier<AuthStatus> {
  fluwx.FluwxCancelable? _authSubscriber;

  @override
  AuthStatus build() {
    // 监听 sessionProvider，刷新后自动恢复登录态
    ref.watch(sessionProvider);
    return AuthStatus.initial;
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);
  SessionNotifier get _session => ref.read(sessionProvider.notifier);

  // ── 微信登录 ────────────────────────────────────────────────────────

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
      if (!success) {
        AppLogger.warning('authBy rejected by native SDK', module: 'wechat', event: 'auth_request_rejected');
      }
    } catch (e, stackTrace) {
      AppLogger.error('WeChat login exception', module: 'wechat', event: 'login_error', error: e, stackTrace: stackTrace);
      state = AuthStatus.unauthenticated;
    }
  }

  /// Web / 测试环境专用：直接写入测试 token，跳过微信授权。
  Future<void> webLogin() async {
    const token = '223281';
    await _session.login(token);
    await _onLoginSuccess();
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
      await _onLoginSuccess();
    } else if (response.code == 295) {
      await _session.savePendingWechatCode(code);
      state = AuthStatus.wechatAuthenticated;
    } else {
      AppLogger.warning('Server rejected login: code=${response.code} msg=${response.message}', module: 'wechat', event: 'server_rejected');
      state = AuthStatus.unauthenticated;
    }
  }

  // ── 手机号登录 ──────────────────────────────────────────────────────

  Future<void> phoneLogin({required String phone, required String code}) async {
    state = AuthStatus.loading;
    final response = await _repository.loginWithPhone(phone: phone, code: code);
    if (response.success) {
      final result = response.data!;
      await _session.login(result.accessToken, refreshToken: result.refreshToken);
      await _onLoginSuccess();
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
      await _onLoginSuccess();
    } else {
      state = AuthStatus.wechatAuthenticated;
    }
  }

  // ── 短信验证码 ──────────────────────────────────────────────────────

  Future<bool> sendSmsCode({required String phone}) async {
    final response = await _repository.sendSmsCode(phone: phone);
    if (!response.success) {
      AppLogger.warning('SMS code request failed', module: 'auth', event: 'send_sms_failed', data: {'code': response.code, 'message': response.message});
    }
    return response.success;
  }

  // ── 登出 / 注销 ─────────────────────────────────────────────────────

  Future<void> logout() async {
    state = AuthStatus.loading;
    _authSubscriber?.cancel();
    _authSubscriber = null;
    // 无论服务端是否成功，均清除本地 Token，避免用户卡在登录态
    final response = await _repository.logout();
    if (!response.success) {
      AppLogger.warning('Server logout failed: code=${response.code} msg=${response.message}', module: 'auth', event: 'logout_server_failed');
    }
    _clearUserProfile();
    await _session.logout();
  }

  /// 注销账号：调用 /api/sys/deluser，成功后清除本地 Session。
  Future<ApiResponse<void>> deleteAccount() async {
    state = AuthStatus.loading;
    final response = await _repository.deleteAccount();
    if (response.success) {
      _clearUserProfile();
      await _session.logout();
    } else {
      AppLogger.warning('Delete account failed: code=${response.code} msg=${response.message}', module: 'auth', event: 'delete_account_failed');
      state = AuthStatus.authenticated;
    }
    return response;
  }

  // ── 工具方法 ────────────────────────────────────────────────────────

  /// 登录成功后的统一后处理：拉取用户资料并更新 AuthStatus。
  ///
  /// 在所有登录路径（微信登录、手机号登录、绑定手机号、Web 测试登录）
  /// token 写入存储后调用。即使资料拉取失败也不影响登录态。
  Future<void> _onLoginSuccess() async {
    state = AuthStatus.authenticated;
    // 后台拉取用户资料，不阻塞登录态切换
    try {
      await ref.read(userProfileProvider.notifier).load();
    } catch (e) {
      AppLogger.warning('Profile load after login failed: $e', module: 'auth', event: 'post_login_profile_failed');
    }
  }

  /// 登出 / 注销时重置用户资料，清除页面上的个人信息。
  void _clearUserProfile() {
    ref.read(userProfileProvider.notifier).clear();
  }

  Future<ApiResponse<UserInfo>> getCurrentUser() async => _repository.getCurrentUser();
  Future<ApiResponse<String>> refreshToken() async => _repository.refreshToken();
  Future<bool> isLoggedIn() async => _repository.isLoggedIn();
}
