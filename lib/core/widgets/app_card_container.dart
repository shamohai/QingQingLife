import 'package:flutter/material.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

/// 紧凑型电商卡片外壳组件
///
/// 统一规范页面各类白底/浅色卡片的圆角、边距、阴影和背景色。
class AppCardContainer extends StatelessWidget {
  const AppCardContainer({
    super.key,
    required this.child,
    this.padding = AppSpacing.edgeInsetsCard,
    this.margin,
    this.borderRadius = AppRadius.md,
    this.backgroundColor = Colors.white,
    this.borderColor,
    this.boxShadow,
    this.onTap,
  });

  /// 卡片内容
  final Widget child;

  /// 内边距（默认 12dp 紧凑边距）
  final EdgeInsetsGeometry padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 圆角半径
  final double borderRadius;

  /// 背景颜色
  final Color backgroundColor;

  /// 边框颜色（可选）
  final Color? borderColor;

  /// 阴影列表（可选）
  final List<BoxShadow>? boxShadow;

  /// 点击回调（可选）
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget result = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      result = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: result,
      );
    }

    return result;
  }
}
