import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_constants.dart';
import '../../core/storage/local_storage.dart';

/// 主题模式 Notifier
///
/// 状态为 [ThemeMode]（system / light / dark），
/// 初始化时从 LocalStorage 读取用户偏好，切换时自动持久化。
class ThemeNotifier extends Notifier<ThemeMode> {
  static const _keySystem = 'system';
  static const _keyLight = 'light';
  static const _keyDark = 'dark';

  final LocalStorage _storage = LocalStorage();

  @override
  ThemeMode build() {
    _loadFromStorage();
    return ThemeMode.system;
  }

  Future<void> _loadFromStorage() async {
    final saved = await _storage.getString(AppConstants.themeModeKey);
    switch (saved) {
      case _keyLight:
        state = ThemeMode.light;
      case _keyDark:
        state = ThemeMode.dark;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final key = mode == ThemeMode.light
        ? _keyLight
        : mode == ThemeMode.dark
            ? _keyDark
            : _keySystem;
    await _storage.putString(AppConstants.themeModeKey, key);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  () => ThemeNotifier(),
  name: 'themeProvider',
);