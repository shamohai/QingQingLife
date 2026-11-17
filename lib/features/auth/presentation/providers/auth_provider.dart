import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/config/app_config.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../member/presentation/providers/user_profile_provider.dart';

enum AuthStatus { initial, loading, authenticated, wechatAuthenticated, unauthenticated }

// Fluwx creates an internal response-stream subscription in its constructor.
// Keep a single instance so provider rebuilds do not accumulate stream listeners.
final fluwx.Fluwx _wechatClient = fluwx.Fluwx();

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(() => AuthNotifier());

class AuthNotifier extends Notifier<AuthStatus> {
  fluwx.FluwxCancelable? _authSubscriber;

  /// 本进程内已处理过的微信授权 code，防止同一个回调被重复消费（如 Activity 残留 Intent）。
  String? _lastHandledWeChatCode;

  @override
  AuthStatus build() {
    // Session 是独立的共享状态源。不能 watch 它，否则 token 持久化时
    // Session 的 loading/authenticated 变化会重建本 Notifier 并重置登录流程状态。
    ref.onDispose(() {
      _authSubscriber?.cancel();
      _authSubscriber = null;
    });
    return AuthStatus.initial;
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);
  SessionNotifier get _session => ref.read(sessionProvider.notifier);
  fluwx.Fluwx get _fluwx => _wechatClient;

  // ── 微信登录 ────────────────────────────────────────────────────────

  Future<void> wechatLogin() async {
    state = AuthStatus.loading;
    _authSubscriber?.cancel();
    _authSubscriber = _fluwx.addSubscriber(_handleWeChatResponse);
    try {
      // bootstrap 中的 registerApi 是异步执行的，冷启动后很快点击时可能尚未完成，
      // 此时 authBy 会直接返回 false 且不会有任何回调。fluwx 允许重复注册，这里再确认一次。
      await _fluwx.registerApi(appId: AppConfig.wechatAppId);
      final launched = await _fluwx.authBy(
        which: fluwx.NormalAuth(scope: 'snsapi_userinfo', state: 'wechat_login'),
      );
      if (!launched) {
        // 微信未拉起时不会有授权回调，必须主动复位，否则页面会一直转圈
        _cancelWeChatSubscriber();
        AppLogger.warning('WeChat auth launch returned false', module: 'auth', event: 'wechat_auth_launch_failed');
        state = AuthStatus.unauthenticated;
      }
    } catch (e, st) {
      _cancelWeChatSubscriber();
      AppLogger.error('WeChat auth launch failed', module: 'auth', event: 'wechat_auth_launch_error', error: e, stackTrace: st);
      state = AuthStatus.unauthenticated;
    }
  }

  /// 冷启动恢复微信授权回调。
  ///
  /// 应用进程在去微信授权期间被系统回收时，授权结果只会以 Activity Intent 的形式保留，
  /// fluwx 不会自动投递给 Dart 层。这里注册监听并请求 fluwx 重新解析当前 Intent。
  /// 没有待处理的微信回调时该调用是空操作。
  Future<void> resumePendingWeChatAuth() async {
    await ref.read(sessionProvider.notifier).ensureInitialized();
    // 已登录则不再处理，避免残留的旧授权 Intent 覆盖当前登录态
    if (ref.read(sessionProvider) == SessionState.authenticated) return;
    try {
      _authSubscriber?.cancel();
      _authSubscriber = _fluwx.addSubscriber(_handleWeChatResponse);
      await _fluwx.registerApi(appId: AppConfig.wechatAppId);
      await _fluwx.attemptToResumeMsgFromWx();
    } catch (e, st) {
      _cancelWeChatSubscriber();
      AppLogger.error('WeChat auth resume failed', module: 'auth', event: 'wechat_auth_resume_error', error: e, stackTrace: st);
    }
  }

  void _cancelWeChatSubscriber() {
    _authSubscriber?.cancel();
    _authSubscriber = null;
  }

  /// Web 测试环境专用：手动填入 authtoken / devid 模拟登录，跳过微信授权。
  ///
  /// 与微信授权登录走完全相同的落库逻辑（[SessionNotifier.login]）：
  /// 写入 accessToken、authtoken、devid 后再拉取用户资料，
  /// 因此刷新页面或重启后登录态可被 [SessionNotifier] 正常恢复。
  Future<void> webTestLogin({required String authToken, required String deviceId}) async {
    state = AuthStatus.loading;
    try {
      await _session.login(authToken, deviceId: deviceId);
      await _onLoginSuccess();
    } catch (e) {
      AppLogger.warning('Web test login failed: $e', module: 'auth', event: 'web_test_login_failed');
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> _handleWeChatResponse(fluwx.WeChatResponse response) async {
    if (response is! fluwx.WeChatAuthResponse) return;
    final code = response.code ?? '';
    _cancelWeChatSubscriber();
    if (state == AuthStatus.authenticated || (code.isNotEmpty && code == _lastHandledWeChatCode)) {
      return;
    }
    if (response.isSuccessful && code.isNotEmpty) {
      _lastHandledWeChatCode = code;
      await _doWeChatLogin(code);
    } else {
      // errCode -2 为用户取消授权，属于正常路径，这里仍记录以便排查
      AppLogger.warning('WeChat auth failed', module: 'auth', event: 'wechat_auth_failed', data: {'errCode': response.errCode, 'errStr': response.errStr});
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> _doWeChatLogin(String code) async {
    try {
      final response = await _repository.loginWithWeChatCode(code: code);
      if (response.success) {
        final result = response.data!;
        await _session.login(result.accessToken, refreshToken: result.refreshToken);
        await _onLoginSuccess();
      } else if (response.code == 295) {
        await _session.savePendingWechatCode(code);
        state = AuthStatus.wechatAuthenticated;
      } else {
        AppLogger.warning('WeChat login rejected: code=${response.code} msg=${response.message}', module: 'auth', event: 'wechat_login_rejected');
        state = AuthStatus.unauthenticated;
      }
    } catch (e, st) {
      // 网络超时、存储写入失败等异常必须复位，否则 authProvider 会永远停在 loading
      AppLogger.error('WeChat login failed', module: 'auth', event: 'wechat_login_error', error: e, stackTrace: st);
      // 已进入 authenticated 后的异常（如资料拉取）不应把登录态打回未登录
      if (state == AuthStatus.loading) state = AuthStatus.unauthenticated;
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

  Future<ApiResponse<AuthResult>> phoneBind({required String phone, required String code}) async {
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
    return response;
  }

  // ── 短信验证码 ──────────────────────────────────────────────────────

  Future<bool> sendBindMobileSmsCode({required String phone}) async {
    final response = await _repository.sendSmsCode(phone: phone, smsType: SmsType.bindUserMobile);
    if (!response.success) {
      AppLogger.warning('SMS code request failed', module: 'auth', event: 'send_sms_failed', data: {'code': response.code, 'message': response.message});
    }
    return response.success;
  }

  // ── 登出 / 注销 ─────────────────────────────────────────────────────

  Future<void> logout() async {
    if (state == AuthStatus.loading) return;
    state = AuthStatus.loading;
    _authSubscriber?.cancel();
    _authSubscriber = null;
    try {
      // 无论服务端是否成功，均清除本地 Token，避免用户卡在登录态
      final response = await _repository.logout();
      if (!response.success) {
        AppLogger.warning('Server logout failed: code=${response.code} msg=${response.message}', module: 'auth', event: 'logout_server_failed');
      }
    } finally {
      _clearUserProfile();
      try {
        await _session.logout();
      } finally {
        state = AuthStatus.unauthenticated;
      }
    }
  }

  /// 注销账号：调用 /api/sys/deluser，成功后清除本地 Session。
  Future<ApiResponse<void>> deleteAccount() async {
    state = AuthStatus.loading;
    final response = await _repository.deleteAccount();
    if (response.success) {
      _clearUserProfile();
      try {
        await _session.logout();
      } finally {
        state = AuthStatus.unauthenticated;
      }
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
    } catch (e, st) {
      AppLogger.error('user profile load after login failed', module: 'auth', event: 'profile_load_after_login_error', error: e, stackTrace: st);
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
