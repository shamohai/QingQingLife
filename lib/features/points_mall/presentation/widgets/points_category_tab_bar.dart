import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';

/// 积分商城分类 Tab 栏（水平可滚动，sticky 钉住）
class PointsCategoryTabBar extends StatelessWidget {
  final List<String> categories;
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
    return Container(
      color: const Color(0xFFF3F5F7),
      child: SizedBox(
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final label = categories[index];
            final isActive = label == activeCategoryId;
            return GestureDetector(
              onTap: () => onCategoryTap(label),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 14).copyWith(
                    color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
