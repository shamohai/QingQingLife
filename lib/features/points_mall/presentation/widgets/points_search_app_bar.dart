import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 积分商城顶部搜索栏（标题 + 搜索框）
class PointsSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final VoidCallback? onSearch;

  const PointsSearchAppBar({super.key, this.searchController, this.onSearch});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                '积分商城',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: '搜索心仪好物',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.outline),
                      prefixIcon: Icon(Icons.search, size: 18, color: AppColors.outline),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: AppSpacing.md),
                        child: Text(
                          '搜索',
                          style: TextStyle(fontSize: 13, color: AppColors.primary),
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => onSearch?.call(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}