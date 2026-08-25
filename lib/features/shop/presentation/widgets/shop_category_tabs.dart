import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/shop_provider.dart';

class ShopCategoryTabs extends ConsumerWidget {
  final String selectedCategoryId;
  final ValueChanged<String> onCategoryChanged;

  const ShopCategoryTabs({
    super.key,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.read(shopDataProvider).categories;
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.id == selectedCategoryId;
          return GestureDetector(
            onTap: () => onCategoryChanged(cat.id),
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.icon, size: 14, color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(cat.label, style: AppTextStyles.labelSmall.copyWith(color: isSelected ? AppColors.onPrimary : AppColors.onSurface)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}