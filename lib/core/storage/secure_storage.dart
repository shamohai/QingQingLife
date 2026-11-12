import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../app/config/app_constants.dart';

// 关键条件导入（关键！）
import 'secure_storage_stub.dart' if (dart.library.html) 'secure_storage_web.dart' as storage;

/// 安全存储封装类
///
/// 专门用于持久化敏感信息（如登录 Token 和 RefreshToken）。
///
/// [实现原理]：
/// - 在 iOS 上使用 Keychain 存储。
/// - 在 Android 上使用 AES 加密的 SharedPreferences。
/// - [安全原则]：禁止将敏感 Token 写入通用的 LocalStorage (SharedPreferences)，以防被调试工具或非法提取。
/// - [Web 适配]：回退到浏览器 localStorage，跨页面导航保留，与 App 端行为一致，退出登录才清除。
///
/// [令牌唯一性]：
/// 服务端返回的 authtoken 就是唯一的登录凭证，只保存在 [AppConstants.authTokenKey]。
/// 历史版本曾另存一份 `access_token`，两者值相同、互不同步，属于冗余：
/// 现已统一到 [authTokenKey]，读取时兼容迁移旧值。
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  /// 历史遗留的访问令牌 Key，仅用于读取迁移，不再写入。
  static const String _legacyAccessTokenKey = 'access_token';

  /// 旧 Key 是否已确认不存在，避免每次读取 token 都多一次存储访问。
  static bool _legacyKeyChecked = false;

  /// 读取登录令牌（authtoken）。
  ///
  /// 若只存在历史 `access_token`，则迁移到统一 Key 后返回，避免升级后掉登录态。
  Future<String?> readAuthToken() async {
    final token = await get(AppConstants.authTokenKey);
    if (token != null && token.isNotEmpty) return token;
    if (_legacyKeyChecked) return token;

    try {
      final legacy = await get(_legacyAccessTokenKey);
      if (legacy == null || legacy.isEmpty) {
        _legacyKeyChecked = true;
        return token;
      }
      await put(AppConstants.authTokenKey, legacy);
      await remove(_legacyAccessTokenKey);
      _legacyKeyChecked = true;
      return legacy;
    } catch (_) {
      // 迁移失败不阻断登录流程，下次读取时再重试
      return token;
    }
  }

  /// 保存登录令牌（authtoken）。
  Future<void> writeAuthToken(String token) => put(AppConstants.authTokenKey, token);

  /// 读取认证请求使用的设备身份。
  Future<String?> readDeviceId() => get(AppConstants.deviceIdKey);

  /// 保存认证请求使用的设备身份。
  Future<void> writeDeviceId(String deviceId) => put(AppConstants.deviceIdKey, deviceId);

  /// 写入刷新令牌
  Future<void> writeRefreshToken(String token) async {
    if (kIsWeb) {
      storage.setLocalStorageItem(AppConstants.refreshTokenKey, token);
      return;
    }
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  /// 通用字符串读写（用于非敏感临时数据，如 pendingWechatCode）
  Future<String?> get(String key) async {
    if (kIsWeb) return storage.getLocalStorageItem(key);
    return await _storage.read(key: key);
  }

  Future<void> put(String key, String value) async {
    if (kIsWeb) {
      storage.setLocalStorageItem(key, value);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<void> remove(String key) async {
    if (kIsWeb) {
      storage.removeLocalStorageItem(key);
      return;
    }
    await _storage.delete(key: key);
  }

  /// 清除所有令牌（登出时调用）
  ///
  /// devid 是设备身份而非用户数据，登出后必须保留：
  /// 否则再次登录会重新生成设备 ID，与后端记录的设备身份不一致。
  Future<void> clearTokens() async {
    await remove(AppConstants.authTokenKey);
    await remove(AppConstants.refreshTokenKey);
    // 一并清理历史遗留 Key，避免旧值残留后又被迁移逻辑读回。
    await remove(_legacyAccessTokenKey);
    _legacyKeyChecked = true;
  }
}
