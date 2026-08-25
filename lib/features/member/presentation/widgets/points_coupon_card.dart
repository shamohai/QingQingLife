import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/user_profile_provider.dart';

/// 积分 / 优惠券快捷统计
class PointsCouponCard extends ConsumerWidget {
  const PointsCouponCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.read(userProfileProvider).memberInfo;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, size: 18, color: Color(0xFFFF8F00)),
                    const SizedBox(width: 4),
                    Text(member.points.toString(), style: AppTextStyles.headlineSmall.copyWith(color: const Color(0xFFFF8F00))),
                  ],
                ),
                const SizedBox(height: 2),
                Text('我的积分', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          Expanded(
            child: Column(
              children: [
                const Text('3', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 2),
                Text('我的优惠券', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}