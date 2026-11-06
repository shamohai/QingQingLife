import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../app/config/app_constants.dart';
import 'secure_storage.dart';

/// 设备 ID 持久化管理
///
/// 对齐 JS 版 `getOrCreateClientId` 逻辑：
/// - 首次启动生成唯一 ID 并持久化
/// - 后续启动直接读取
///
/// 存储 Key 统一使用 [AppConstants.deviceIdKey]，与认证请求读取的
/// `devid` 保持同一份数据，避免两套 Key 造成设备身份不一致。
class DeviceStorage {
  static final SecureStorage _storage = SecureStorage();

  /// 旧版本使用 SharedPreferences 保存设备 ID 的 Key。
  /// 仅用于一次性迁移，迁移后不再写入。
  static const String _legacyDeviceIdKey = 'qingqinglife-device-id';

  /// 获取或生成设备 ID
  static Future<String> getDeviceId() async {
    final existing = await _readStoredDeviceId();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    // 生成新 ID：时间戳 + 4位随机数（对齐 JS 版逻辑）
    final min = 1000;
    final rand = min + Random().nextInt(9000);
    final deviceId = '${DateTime.now().millisecondsSinceEpoch}$rand';
    await _storage.writeDeviceId(deviceId);
    return deviceId;
  }

  /// 读取已保存的设备 ID；若只在旧 Key 中存在，则迁移到统一 Key。
  static Future<String?> _readStoredDeviceId() async {
    final current = await _storage.readDeviceId();
    if (current != null && current.isNotEmpty) return current;

    try {
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getString(_legacyDeviceIdKey);
      if (legacy == null || legacy.isEmpty) return current;
      await _storage.writeDeviceId(legacy);
      await prefs.remove(_legacyDeviceIdKey);
      return legacy;
    } catch (_) {
      // 迁移失败不阻断启动，继续按新逻辑生成设备 ID
      return current;
    }
  }
}
