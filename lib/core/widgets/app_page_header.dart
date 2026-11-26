import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Shared page header with independently configurable left, center, and right
/// content. Set [safeAreaTop] when using it directly as a [Scaffold.appBar].
class AppPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppPageHeader({
    this.title,
    this.onBack,
    this.left,
    this.center,
    this.right,
    this.titleStyle = AppTextStyles.headlineSmall,
    this.iconColor = AppColors.onSurface,
    this.backgroundColor,
    this.backIcon = Icons.arrow_back_ios_new,
    this.iconSize = 22,
    this.height = 44,
    this.leadingWidth = 44,
    this.titleSpacing = 0,
    this.centerAlignment = Alignment.centerLeft,
    this.centerTitle = false,
    this.safeAreaTop = false,
    super.key,
  }) : assert(height >= 44),
       assert(leadingWidth >= 44),
       assert(center == null || title == null);

  final String? title;
  final VoidCallback? onBack;
  final Widget? left;
  final Widget? center;
  final Widget? right;
  final TextStyle titleStyle;
  final Color iconColor;
  final Color? backgroundColor;
  final IconData backIcon;
  final double iconSize;
  final double height;
  final double leadingWidth;
  final double titleSpacing;
  final AlignmentGeometry centerAlignment;
  final bool centerTitle;
  final bool safeAreaTop;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final leading = left ?? _buildBackButton(context);
    final centerContent = center ?? _buildTitle();
    final trailing = right ?? (centerTitle && leading != null ? SizedBox(width: leadingWidth, height: height) : null);

    final row = SizedBox(
      height: height,
      child: Row(
        children: [
          ?leading,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: titleSpacing),
              child: Align(alignment: centerTitle ? Alignment.center : centerAlignment, child: centerContent ?? const SizedBox.shrink()),
            ),
          ),
          ?trailing,
        ],
      ),
    );

    if (safeAreaTop) {
      final topInset = MediaQuery.viewPaddingOf(context).top;
      return Container(
        color: backgroundColor,
        child: Padding(
          padding: EdgeInsets.only(top: topInset),
          child: row,
        ),
      );
    }
    return Container(height: height, color: backgroundColor, child: row);
  }

  Widget? _buildBackButton(BuildContext context) {
    if (onBack == null) return null;
    return SizedBox(
      width: leadingWidth,
      height: height,
      child: IconButton(
        icon: Icon(backIcon, color: iconColor, size: iconSize),
        onPressed: onBack,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      ),
    );
  }

  Widget? _buildTitle() {
    if (title == null) return null;
    return Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis, style: titleStyle);
  }
}
