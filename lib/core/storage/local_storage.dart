import 'package:shared_preferences/shared_preferences.dart';

/// 本地通用存储封装
/// 
/// 基于 [shared_preferences] 实现，主要用于存储非敏感的持久化配置数据，
/// 例如：是否首次启动、App 语言设置、缓存的非敏感 UI 状态等。
/// 对于敏感信息（如 Token），应优先使用 SecureStorage。
class LocalStorage {
  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// 获取字符串类型数据
  Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  /// 存储字符串类型数据
  Future<void> putString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  /// 获取布尔类型数据
  Future<bool?> getBool(String key) async {
    final prefs = await _prefs;
    return prefs.getBool(key);
  }

  /// 存储布尔类型数据
  Future<void> putBool(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  /// 移除指定 key 的数据
  Future<bool> remove(String key) async {
    final prefs = await _prefs;
    return await prefs.remove(key);
  }

  /// 清空所有 SharedPreferences 存储的数据
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
