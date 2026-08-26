import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../app/config/app_constants.dart';

/// 安全存储封装，仅用于敏感信息（Token）。
///
/// 使用 [flutter_secure_storage]，数据存储在系统安全存储中。
/// 禁止将 Token 写入 SharedPreferences。
/// Web 环境下回退到内存存储（flutter_secure_storage Web 需要 HTTPS）。
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  // Web 环境下的内存回退存储
  static String? _webAccessToken;
  static String? _webRefreshToken;

  Future<String?> readAccessToken() async {
    if (kIsWeb) return _webAccessToken;
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  Future<void> writeAccessToken(String token) async {
    if (kIsWeb) {
      _webAccessToken = token;
      return;
    }
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<String?> readRefreshToken() async {
    if (kIsWeb) return _webRefreshToken;
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> writeRefreshToken(String token) async {
    if (kIsWeb) {
      _webRefreshToken = token;
      return;
    }
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<void> clearTokens() async {
    if (kIsWeb) {
      _webAccessToken = null;
      _webRefreshToken = null;
      return;
    }
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
}
