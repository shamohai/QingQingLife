import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../../core/widgets/app_image.dart';

/// 金刚区：5格图标导航（使用 API iconUrl 图片）
class HomeKingKongGrid extends StatelessWidget {
  final List<HomeKingKongItem> items;

  const HomeKingKongGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
        ),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 5,
          childAspectRatio: 0.8,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          children: List.generate(items.length, (i) => _KingKongItem(item: items[i])),
        ),
      ),
    );
  }
}

class _KingKongItem extends StatelessWidget {
  final HomeKingKongItem item;
  const _KingKongItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: item.iconUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: AppNetworkImage(url: item.iconUrl, fit: BoxFit.cover),
                )
              : const Center(
                  child: Icon(Icons.category_outlined, size: 26, color: AppColors.primary),
                ),
        ),
        const SizedBox(height: 4),
        Text(item.label, style: AppTextStyles.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}