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
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
  name: 'sessionProvider',
);