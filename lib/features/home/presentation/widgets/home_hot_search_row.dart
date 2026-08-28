import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 热搜词横向滚动行
class HomeHotSearchRow extends StatelessWidget {
  final List<String> keywords;
  final ValueChanged<String>? onKeywordTap;

  const HomeHotSearchRow({super.key, required this.keywords, this.onKeywordTap});

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: keywords.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _HotKeywordChip(label: '热词', isBadge: true);
          }
          final keyword = keywords[index - 1];
          return Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: _HotKeywordChip(
              label: keyword,
              onTap: () => onKeywordTap?.call(keyword),
            ),
          );
        },
      ),
    );
  }
}

class _HotKeywordChip extends StatelessWidget {
  final String label;
  final bool isBadge;
  final VoidCallback? onTap;

  const _HotKeywordChip({required this.label, this.isBadge = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isBadge ? const Color(0xFFE53935) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isBadge ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}