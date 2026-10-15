import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web/web.dart' as web;

import '../../app/config/app_constants.dart';

/// 安全存储封装类
///
/// 专门用于持久化敏感信息（如 AccessToken 和 RefreshToken）。
///
/// [实现原理]：
/// - 在 iOS 上使用 Keychain 存储。
/// - 在 Android 上使用 AES 加密的 SharedPreferences。
/// - [安全原则]：禁止将敏感 Token 写入通用的 LocalStorage (SharedPreferences)，以防被调试工具或非法提取。
/// - [Web 适配]：回退到浏览器 localStorage，跨页面导航保留，与 App 端行为一致，退出登录才清除。
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  /// 读取访问令牌
  Future<String?> readAccessToken() async {
    if (kIsWeb) return web.window.localStorage.getItem(AppConstants.accessTokenKey);
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  /// 写入访问令牌
  Future<void> writeAccessToken(String token) async {
    if (kIsWeb) {
      web.window.localStorage.setItem(AppConstants.accessTokenKey, token);
      return;
    }
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  /// 读取认证请求使用的设备身份。
  Future<String?> readDeviceId() => get(AppConstants.deviceIdKey);

  /// 保存认证请求使用的设备身份。
  Future<void> writeDeviceId(String deviceId) => put(AppConstants.deviceIdKey, deviceId);

  /// 读取服务端用户身份 Token（authtoken）。
  Future<String?> readAuthToken() => get(AppConstants.authTokenKey);

  /// 保存服务端用户身份 Token（authtoken）。
  Future<void> writeAuthToken(String token) => put(AppConstants.authTokenKey, token);

  /// 读取刷新令牌
  Future<String?> readRefreshToken() async {
    if (kIsWeb) return web.window.localStorage.getItem(AppConstants.refreshTokenKey);
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  /// 写入刷新令牌
  Future<void> writeRefreshToken(String token) async {
    if (kIsWeb) {
      web.window.localStorage.setItem(AppConstants.refreshTokenKey, token);
      return;
    }
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  /// 通用字符串读写（用于非敏感临时数据，如 pendingWechatCode）
  Future<String?> get(String key) async {
    if (kIsWeb) return web.window.localStorage.getItem(key);
    return await _storage.read(key: key);
  }

  Future<void> put(String key, String value) async {
    if (kIsWeb) {
      web.window.localStorage.setItem(key, value);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<void> remove(String key) async {
    if (kIsWeb) {
      web.window.localStorage.removeItem(key);
      return;
    }
    await _storage.delete(key: key);
  }

  /// 清除所有令牌（登出时调用）
  Future<void> clearTokens() async {
    if (kIsWeb) {
      web.window.localStorage.removeItem(AppConstants.accessTokenKey);
      web.window.localStorage.removeItem(AppConstants.refreshTokenKey);
      web.window.localStorage.removeItem(AppConstants.deviceIdKey);
      web.window.localStorage.removeItem(AppConstants.authTokenKey);
      return;
    }
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.deviceIdKey);
    await _storage.delete(key: AppConstants.authTokenKey);
  }
}
