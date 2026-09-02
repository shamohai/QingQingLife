import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

/// 通用按钮组件
/// 
/// 遵循青轻生活馆设计规范，支持三种预设样式（主要、次要、幽灵）。
/// 特性：
/// 1. 自动处理 Loading 状态，并在加载时禁用点击以防止重复请求。
/// 2. 统一的高度和圆角配置。
/// 3. 支持全宽展示或指定宽度。
enum AppButtonStyle { 
  primary,    // 主按钮：实色背景，高对比度文字
  secondary,  // 次按钮：浅色背景，通常用于辅助操作
  ghost       // 幽灵按钮：仅边框，用于弱化操作
}

class AppButton extends StatelessWidget {
  final String label;         // 按钮文字
  final VoidCallback? onPressed; // 点击回调，为 null 时按钮进入禁用状态
  final bool isLoading;       // 是否处于加载状态
  final AppButtonStyle style; // 按钮样式风格
  final double? width;        // 按钮宽度，不传则默认全宽（取决于父容器）

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.style = AppButtonStyle.primary,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // 只有在没有加载中且提供了回调函数时才启用按钮
    final isEnabled = onPressed != null && !isLoading;

    Widget child = SizedBox(
      width: double.infinity,
      height: 44, // 统一标准高度
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2), // 加载菊花
              )
            : Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
              ),
      ),
    );

    // 根据不同风格选择底层的 Button 组件
    if (style == AppButtonStyle.ghost) {
      child = OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: _textColor,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          minimumSize: const Size.fromHeight(44),
        ),
        child: child,
      );
    } else {
      child = ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _bgColor,
          foregroundColor: _textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          minimumSize: const Size.fromHeight(44),
        ),
        child: child,
      );
    }

    return SizedBox(width: width, child: child);
  }

  /// 根据样式动态获取背景色
  Color get _bgColor {
    switch (style) {
      case AppButtonStyle.primary:
        return AppColors.primary;
      case AppButtonStyle.secondary:
        return AppColors.secondaryContainer;
      case AppButtonStyle.ghost:
        return Colors.transparent;
    }
  }

  /// 根据样式动态获取文字颜色
  Color get _textColor {
    switch (style) {
      case AppButtonStyle.primary:
        return AppColors.onPrimary;
      case AppButtonStyle.secondary:
        return AppColors.secondary;
      case AppButtonStyle.ghost:
        return AppColors.primary;
    }
  }
}
