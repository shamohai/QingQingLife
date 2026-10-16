import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/widgets/app_image.dart';

/// 每月权益展示卡片
/// 设计稿：白色卡片，"每月权益" 标题 + 副标题，5个权益项（56x56 图片 + 橙色胶囊"领取"按钮）
class HomeMonthlyBenefits extends StatelessWidget {
  final List<HomeMonthlyBenefit> benefits;
  final ValueChanged<HomeMonthlyBenefit>? onClaimTap;

  const HomeMonthlyBenefits({super.key, required this.benefits, this.onClaimTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(14)), // 设计稿 14px 圆角
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Image.asset(
                'assets/images/home/kingkong_member.png',
                width: 16,
                height: 16,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                  child: const Icon(Icons.card_membership, size: 10, color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('每月权益', style: AppTextStyles.headlineSmall),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '(权益月月享，每月只可领取一个)',
                  style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF999999), fontSize: 10),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 5个权益项
          if (benefits.isEmpty)
            const Text('暂无权益', style: AppTextStyles.bodySmall)
          else
            Row(
              children: benefits.take(5).map((benefit) {
                final index = benefits.indexOf(benefit);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index < 4 ? 6 : 0),
                    child: _BenefitSlot(benefit: benefit, onTap: onClaimTap),
                  ),
                );
              }).toList(),
            ),
        ],
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 52x52 图片
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFCDD2), width: 0.6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: benefit.imageUrl != null && benefit.imageUrl!.isNotEmpty
                  ? AppNetworkImage(url: benefit.imageUrl!, fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.stars, size: 26, color: Color(0xFFE53935))),
            ),
          ),
          const SizedBox(height: 6),
          // 红色胶囊"领取"按钮
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Text(
                '领取',
                style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
