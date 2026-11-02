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
      final accessToken = await _storage.readAuthToken() ?? await _storage.readAccessToken();
      if (!ref.mounted) return;
      if (generation == _operationGeneration && state == SessionState.loading) {
        state = accessToken != null && accessToken.isNotEmpty ? SessionState.authenticated : SessionState.unauthenticated;
      }
    } catch (_) {
      if (!ref.mounted) return;
      if (generation == _operationGeneration && state == SessionState.loading) state = SessionState.unauthenticated;
    }
  }

  Future<void> login(String accessToken, {String? refreshToken}) async {
    _operationGeneration++;
    state = SessionState.loading;
    await _storage.writeAccessToken(accessToken);
    await _storage.writeAuthToken(accessToken);
    final deviceId = await _storage.readDeviceId() ?? await DeviceStorage.getDeviceId();
    await _storage.writeDeviceId(deviceId);
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
