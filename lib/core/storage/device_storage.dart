import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_security_constants.dart';

/// 设备 ID 持久化管理
/// 
/// 对齐 JS 版 `getOrCreateClientId` 逻辑：
/// - 首次启动生成唯一 ID 并持久化
/// - 后续启动直接读取
class DeviceStorage {
  static const _key = ApiSecurityConstants.deviceIdStorageKey;

  /// 获取或生成设备 ID
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    // 生成新 ID：时间戳 + 4位随机数（对齐 JS 版逻辑）
    final min = 1000;
    final max = 9999;
    final rand = min + DateTime.now().millisecondsSinceEpoch.remainder(max - min);
    final deviceId = '${DateTime.now().millisecondsSinceEpoch}$rand';
    await prefs.setString(_key, deviceId);
    return deviceId;
  }
}
