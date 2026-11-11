import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';

/// 紧凑型通用模块标题栏组件
///
/// 适用于首页、积分商城、会员中心等区块标题区，
/// 支持主标题、小字幕、图标前缀以及右侧“更多”点击按钮。
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.moreText,
    this.onMoreTap,
    this.titleColor,
    this.trailing,
    this.leadingIcon,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
  });

  /// 主标题
  final String title;

  /// 副标题/说明文字
  final String? subtitle;

  /// 右侧操作文案（如 "更多"）
  final String? moreText;

  /// 点击右侧操作回调
  final VoidCallback? onMoreTap;

  /// 标题颜色（为空时使用默认高对比度色）
  final Color? titleColor;

  /// 自定义右侧控件
  final Widget? trailing;

  /// 前置图标（可选）
  final Widget? leadingIcon;

  /// 边距
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: titleColor ?? const Color(0xFF111111),
              height: 1.2,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          const Spacer(),
          if (trailing != null)
            trailing!
          else if (moreText != null && moreText!.isNotEmpty)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onMoreTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      moreText!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF888888),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
