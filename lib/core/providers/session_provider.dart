import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/device_storage.dart';
import '../storage/secure_storage.dart';

enum SessionState { loading, authenticated, unauthenticated }

class SessionNotifier extends Notifier<SessionState> {
  final SecureStorage _storage = SecureStorage();
  late final Future<void> _initialization;
  int _operationGeneration = 0;

  @override
  SessionState build() {
    _initialization = _restoreSession();
    return SessionState.loading;
  }

  Future<void> ensureInitialized() => _initialization;

  Future<void> _restoreSession() async {
    final generation = _operationGeneration;
    try {
      final token = await _storage.readAuthToken();
      if (!ref.mounted) return;
      if (generation == _operationGeneration && state == SessionState.loading) {
        state = token != null && token.isNotEmpty ? SessionState.authenticated : SessionState.unauthenticated;
      }
    } catch (_) {
      if (!ref.mounted) return;
      if (generation == _operationGeneration && state == SessionState.loading) state = SessionState.unauthenticated;
    }
  }

  /// 保存登录状态。
  ///
  /// 所有登录路径（微信授权、手机号、绑定手机号、Web 测试登录）都经过这里，
  /// 只写入一份 authtoken 与 devid，避免同一凭证在多处存储产生不一致。
  ///
  /// [deviceId] 仅在 Web 测试登录等需要人工指定设备身份时传入；
  /// 未传入时复用已保存的设备 ID，不存在才生成新的。
  Future<void> login(String authToken, {String? refreshToken, String? deviceId}) async {
    _operationGeneration++;
    state = SessionState.loading;
    final resolvedDeviceId = (deviceId != null && deviceId.isNotEmpty) ? deviceId : await DeviceStorage.getDeviceId();
    await _storage.writeAuthToken(authToken);
    await _storage.writeDeviceId(resolvedDeviceId);
    if (refreshToken != null) {
      await _storage.writeRefreshToken(refreshToken);
    }
    state = SessionState.authenticated;
  }

  Future<void> logout() async {
    _operationGeneration++;
    state = SessionState.loading;
    try {
      await _storage.clearTokens();
    } finally {
      // 即使本地存储清理失败，也要让界面退出登录态，避免页面一直停在 loading。
      state = SessionState.unauthenticated;
    }
  }

  Future<void> savePendingWechatCode(String code) async {
    await _storage.put('pending_wechat_code', code);
  }

  Future<String?> readPendingWechatCode() async {
    return await _storage.get('pending_wechat_code');
  }

  Future<void> clearPendingWechatCode() async {
    await _storage.remove('pending_wechat_code');
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new, name: 'sessionProvider');
