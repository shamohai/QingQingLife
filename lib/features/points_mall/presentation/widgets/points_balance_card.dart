import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/points_mall_provider.dart';

class PointsBalanceCard extends ConsumerWidget {
  const PointsBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.read(pointsMallDataProvider);
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D52), Color(0xFF4A9C6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [const BoxShadow(color: Color(0x292E7D52), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('我的积分', style: AppTextStyles.labelMedium.copyWith(color: const Color(0xFFB3DFC7))),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(data.currentPoints.toString(), style: AppTextStyles.headlineLarge.copyWith(color: Colors.white, fontSize: 36)),
              const SizedBox(width: 8),
              Text('积分', style: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFFB3DFC7))),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (data.expiringPoints > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(color: const Color(0xFFFF8F00).withAlpha(51), borderRadius: BorderRadius.circular(AppRadius.round)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFFF8F00)),
                  const SizedBox(width: 4),
                  Text('\${data.expiringPoints}积分即将过期', style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFFFF8F00))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
