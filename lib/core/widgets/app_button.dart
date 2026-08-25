import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

/// 统一按钮组件，支持 loading 状态和防重复点击
enum AppButtonStyle { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonStyle style;
  final double? width;

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
    final isEnabled = onPressed != null && !isLoading;

    Widget child = SizedBox(
      width: double.infinity,
      height: 44,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
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