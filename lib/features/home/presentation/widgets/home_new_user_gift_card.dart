import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';

/// 新人礼：纯内容组件，无 padding/容器，由父级 HomePromoSection 统一管理布局
class HomeNewUserGiftCard extends StatelessWidget {
  final List<HomeNewUserGift> gifts;

  const HomeNewUserGiftCard({super.key, required this.gifts});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _GiftCard extends StatelessWidget {
  final String title;
  const _GiftCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(color: AppColors.overlay, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
