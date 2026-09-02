import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../app/config/app_constants.dart';

/// 安全存储封装类
/// 
/// 专门用于持久化敏感信息（如 AccessToken 和 RefreshToken）。
/// 
/// [实现原理]：
/// - 在 iOS 上使用 Keychain 存储。
/// - 在 Android 上使用 AES 加密的 SharedPreferences。
/// - [安全原则]：禁止将敏感 Token 写入通用的 LocalStorage (SharedPreferences)，以防被调试工具或非法提取。
/// - [Web 适配]：由于浏览器端的 flutter_secure_storage 需要 HTTPS 且实现各异，此处在 Web 环境下自动回退到内存存储。
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  // Web 环境下的内存回退存储，页面刷新后会失效
  static String? _webAccessToken;
  static String? _webRefreshToken;

  /// 读取访问令牌
  Future<String?> readAccessToken() async {
    if (kIsWeb) return _webAccessToken;
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  /// 写入访问令牌
  Future<void> writeAccessToken(String token) async {
    if (kIsWeb) {
      _webAccessToken = token;
      return;
    }
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  /// 读取刷新令牌
  Future<String?> readRefreshToken() async {
    if (kIsWeb) return _webRefreshToken;
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  /// 写入刷新令牌
  Future<void> writeRefreshToken(String token) async {
    if (kIsWeb) {
      _webRefreshToken = token;
      return;
    }
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  /// 清除所有令牌（登出时调用）
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

