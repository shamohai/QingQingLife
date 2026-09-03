import 'package:flutter/material.dart';

/// 青轻生活馆品牌色板（亮色 + 暗色双模式）
abstract final class AppColors {
  // ── 亮色（Light）────────────────────────────────────────────────────

  // 主色（蓝色系）
  static const Color primary = Color(0xFF0e55b4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD8E2FF);
  static const Color onPrimaryContainer = Color(0xFF001939);

  // 辅色
  static const Color secondary = Color(0xFF5e95f1);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDEE7FF);
  static const Color onSecondaryContainer = Color(0xFF071A3A);

  // 背景
  static const Color surface = Color(0xFFF8FAF9);
  static const Color onSurface = Color(0xFF1A1D1C);
  static const Color surfaceVariant = Color(0xFFE1E4DC);
  static const Color onSurfaceVariant = Color(0xFF444843);
  static const Color background = Color(0xFFF8FAF9);
  static const Color onBackground = Color(0xFF1A1D1C);

  // 错误/状态
  static const Color error = Color(0xFFFF4D4F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);

  // 成功
  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // 警告
  static const Color warning = Color(0xFFFFC107);
  static const Color onSuccessVariant = Color(0xFF394E00);

  // 边框与分割线
  static const Color outline = Color(0xFF747872);
  static const Color outlineVariant = Color(0xFFC4C8BF);
  static const Color divider = Color(0xFFE1E4DC);

  // 覆盖层
  static const Color overlay = Color(0x1F000000);
  static const Color scrim = Color(0x52000000);

  // ── 暗色（Dark）─────────────────────────────────────────────────────
  // 命名与亮色对称，便于 ThemeData 中按需引用

  static const Color darkPrimary = Color(0xFF578DF7);
  static const Color darkOnPrimary = Color(0xFF002D6A);
  static const Color darkPrimaryContainer = Color(0xFF00439A);
  static const Color darkOnPrimaryContainer = Color(0xFFD8E2FF);

  static const Color darkSecondary = Color(0xFFB3CFFF);
  static const Color darkOnSecondary = Color(0xFF122F5A);
  static const Color darkSecondaryContainer = Color(0xFF294672);
  static const Color darkOnSecondaryContainer = Color(0xFFDEE7FF);

  static const Color darkSurface = Color(0xFF1A1D1C);
  static const Color darkOnSurface = Color(0xFFE8EBE6);
  static const Color darkSurfaceVariant = Color(0xFF2D312C);
  static const Color darkOnSurfaceVariant = Color(0xFFC4C8BF);
  static const Color darkBackground = Color(0xFF1A1D1C);
  static const Color darkOnBackground = Color(0xFFE8EBE6);

  static const Color darkError = Color(0xFFFF5449);
  static const Color darkOnError = Color(0xFF68000B);
  static const Color darkErrorContainer = Color(0xFF93000F);
  static const Color darkOnErrorContainer = Color(0xFFF9DEDC);

  static const Color darkOutline = Color(0xFF8A8E88);
  static const Color darkOutlineVariant = Color(0xFF444843);
  static const Color darkDivider = Color(0xFF3A3E39);

  static const Color darkSuccess = Color(0xFF69D676);
  static const Color darkWarning = Color(0xFFFFB84D);
}