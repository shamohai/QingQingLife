import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

enum SessionState { loading, authenticated, unauthenticated }

class SessionNotifier extends Notifier<SessionState> {
  final SecureStorage _storage = SecureStorage();

  @override
  SessionState build() => SessionState.loading;

  Future<void> login(String accessToken, {String? refreshToken}) async {
    await _storage.writeAccessToken(accessToken);
    if (refreshToken != null) {
      await _storage.writeRefreshToken(refreshToken);
    }
    state = SessionState.authenticated;
  }

  Future<void> logout() async {
    await _storage.clearTokens();
    state = SessionState.unauthenticated;
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

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
  name: 'sessionProvider',
);