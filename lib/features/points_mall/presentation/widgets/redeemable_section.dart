import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/points_mall_home_data.dart';
import 'points_product_card.dart';

class RedeemableSection extends StatelessWidget {
  final List<PointsRedeemGroup> groups;
  final void Function(PointsProduct)? onExchange;

  const RedeemableSection({super.key, required this.groups, this.onExchange});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.map((group) => _RedeemGroup(group: group, onExchange: onExchange)).toList(),
    );
  }
}

class _RedeemGroup extends StatelessWidget {
  final PointsRedeemGroup group;
  final void Function(PointsProduct)? onExchange;

  const _RedeemGroup({required this.group, this.onExchange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Text(group.rangeLabel, style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (group.products.isEmpty) const SizedBox.shrink()
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.6,
                children: group.products.map((p) => PointsProductCard(product: p, compact: true, onExchange: onExchange != null ? () => onExchange!(p) : null)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
