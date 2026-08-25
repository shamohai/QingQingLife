import 'package:flutter/material.dart';

/// 青轻生活馆品牌色板
abstract final class AppColors {
  // 主色（青绿色系，参考东方甄选自然风格）
  static const Color primary = Color(0xFF2E7D52);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFB3DFC7);
  static const Color onPrimaryContainer = Color(0xFF002110);

  // 辅色
  static const Color secondary = Color(0xFF5B6E4E);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDFF4C9);
  static const Color onSecondaryContainer = Color(0xFF181E09);

  // 背景
  static const Color surface = Color(0xFFF8FAF9);
  static const Color onSurface = Color(0xFF1A1D1C);
  static const Color surfaceVariant = Color(0xFFE1E4DC);
  static const Color onSurfaceVariant = Color(0xFF444843);
  static const Color background = Color(0xFFF8FAF9);
  static const Color onBackground = Color(0xFF1A1D1C);

  // 错误/状态
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);

  // 成功
  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // 警告
  static const Color warning = Color(0xFFFF8F00);
  static const Color onSuccessVariant = Color(0xFF394E00);

  // 边框与分割线
  static const Color outline = Color(0xFF747872);
  static const Color outlineVariant = Color(0xFFC4C8BF);
  static const Color divider = Color(0xFFE1E4DC);

  // 覆盖层
  static const Color overlay = Color(0x1F000000);
  static const Color scrim = Color(0x52000000);
}
