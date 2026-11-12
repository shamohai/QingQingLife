import 'package:flutter/widgets.dart';

/// 青轻生活间距规范（基于 4dp 栅格 & 紧凑型电商设计）
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 48;

  // ── 紧凑型电商布局语义常量 ────────────────────────────────────────────────
  /// 页面左右外边距（紧凑型推荐 12.0dp）
  static const double compactPageMargin = md;

  /// 卡片紧凑内边距（10.0dp 或 12.0dp）
  static const double compactCardPadding = md;

  /// 紧凑元素/卡片微间距（8.0dp）
  static const double compactItemGap = sm;

  /// 紧凑模块段落间距（12.0dp）
  static const double compactSectionGap = md;

  // ── 常用 EdgeInsets 快捷封装 ──────────────────────────────────────────────
  /// 页面左右紧凑内边距 EdgeInsets.symmetric(horizontal: 12)
  static const EdgeInsets edgeInsetsCompactPage = EdgeInsets.symmetric(horizontal: compactPageMargin);

  /// 页面左右外边距（与 [compactPageMargin] 一致，供页面级布局统一引用）
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: compactPageMargin);

  /// 页面主体首块顶部间距（统一为 8，见实施计划第二批）
  static const double pageTopGap = sm;

  /// 卡片内边距 EdgeInsets.all(12)
  static const EdgeInsets edgeInsetsCard = EdgeInsets.all(compactCardPadding);
}
