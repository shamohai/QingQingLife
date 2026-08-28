import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';

/// 新人礼优惠券卡片（白色卡片样式）
class HomeNewUserGiftCard extends StatelessWidget {
  final List<HomeNewUserGift> gifts;

  const HomeNewUserGiftCard({super.key, required this.gifts});

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
            Text('新人礼', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            if (gifts.isEmpty)
              const Text('暂无新人礼', style: AppTextStyles.bodySmall)
            else
              Row(
                children: gifts.take(3).map((gift) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _GiftCard(title: gift.title),
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  final String title;
  const _GiftCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlay,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
            child: const Center(
              child: Icon(Icons.card_giftcard, size: 22, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(title, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}