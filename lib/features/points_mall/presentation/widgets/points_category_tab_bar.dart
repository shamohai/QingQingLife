import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/points_mall_home_data.dart';

/// 分类 Tab 栏（水平可滚动）
class PointsCategoryTabBar extends StatelessWidget {
  final List<PointsCategory> categories;
  final String activeCategoryId;
  final ValueChanged<String> onCategoryTap;

  const PointsCategoryTabBar({
    super.key,
    required this.categories,
    required this.activeCategoryId,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = cat.id == activeCategoryId;
          return GestureDetector(
            onTap: () => onCategoryTap(cat.id),
            child: SizedBox(
              height: 26,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      cat.label,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}