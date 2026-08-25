import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../app/config/app_constants.dart';

/// 安全存储封装，仅用于敏感信息（Token）。
///
/// 使用 [flutter_secure_storage]，数据存储在系统安全存储中。
/// 禁止将 Token 写入 SharedPreferences。
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  Future<String?> readAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  Future<void> writeAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> writeRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
}