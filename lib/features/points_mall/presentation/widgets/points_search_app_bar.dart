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
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            Text(
              '积分商城',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
                fontSize: 18,
              ),
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
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '搜索心仪好物',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.outline),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.outline),
                    suffixIcon: InkWell(
                      onTap: onSearch,
                      borderRadius: BorderRadius.circular(AppRadius.round),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '搜索',
                              style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
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
    );
  }
}
