import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/home_provider.dart';

/// 新人礼优惠券卡片
class HomeNewUserGiftCard extends ConsumerWidget {
  const HomeNewUserGiftCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gifts = ref.read(homeDataProvider).newUserGifts;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('新人专享福利', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.warning)),
                  const SizedBox(height: AppSpacing.sm),
                  ...gifts.map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '\\',
                          style: AppTextStyles.bodySmall,
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Text('立即领取', style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}