import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/widgets/app_image.dart';

/// 每月权益展示卡片
class HomeMonthlyBenefits extends StatelessWidget {
  final List<HomeMonthlyBenefit> benefits;
  final ValueChanged<HomeMonthlyBenefit>? onClaimTap;

  const HomeMonthlyBenefits({super.key, required this.benefits, this.onClaimTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, size: 16, color: AppColors.outline),
                const SizedBox(width: AppSpacing.sm),
                Text('每月权益', style: AppTextStyles.headlineSmall),
                const Spacer(),
                Text(
                  '(权益月月享，每月只可领取一个)',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (benefits.isEmpty)
              const Text('暂无权益', style: AppTextStyles.bodySmall)
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.7,
                children: benefits.take(5).map((benefit) => _BenefitSlot(benefit: benefit, onTap: onClaimTap)).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _BenefitSlot extends StatelessWidget {
  final HomeMonthlyBenefit benefit;
  final ValueChanged<HomeMonthlyBenefit>? onTap;

  const _BenefitSlot({required this.benefit, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(benefit),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: benefit.imageUrl != null && benefit.imageUrl!.isNotEmpty
                ? AppNetworkImage(
                    url: benefit.imageUrl!,
                    fit: BoxFit.cover,
                    radius: AppRadius.md,
                  )
                : const Center(child: Icon(Icons.place, size: 24, color: AppColors.outline)),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
            child: const Text(
              '领取',
              style: TextStyle(fontSize: 11, color: AppColors.onPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}