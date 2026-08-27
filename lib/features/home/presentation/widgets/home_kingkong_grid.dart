import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';

/// 金刚区：6格图标导航
class HomeKingKongGrid extends StatelessWidget {
  final List<HomeKingKongItem> items;

  const HomeKingKongGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final icons = <IconData>[
      Icons.storefront_outlined,
      Icons.local_florist,
      Icons.coffee,
      Icons.card_giftcard_outlined,
      Icons.whatshot_outlined,
      Icons.event_outlined,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 6,
        childAspectRatio: 0.85,
        children: List.generate(
          items.length,
          (i) => _KingKongItem(
            icon: Icon(icons[i], size: 28, color: AppColors.primary),
            label: items[i].label,
          ),
        ),
      ),
    );
  }
}

class _KingKongItem extends StatelessWidget {
  final Widget icon;
  final String label;
  const _KingKongItem({required this.icon, required this.label});

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
          child: Center(child: icon),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
