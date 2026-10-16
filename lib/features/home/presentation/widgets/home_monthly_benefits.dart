import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/widgets/app_image.dart';

/// 每月权益展示卡片（支持横向滑动，对齐蓝湖设计规范）
/// 标题行副标题紧跟在标题后，权益图片 quanyi_0 ~ quanyi_5，37x17 #fffb9126 胶囊"领取"按钮
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
          // 标题行：图标 + "每月权益" + 紧跟后方的副标题文字
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
              const SizedBox(width: 6),
              // 副标题文字紧跟在“每月权益”后边 (#ff8e8e93, 9sp)
              Expanded(
                child: Text(
                  '(权益月月享，每月只可领取一个)',
                  style: const TextStyle(
                    color: Color(0xFF8E8E93), // #ff8e8e93
                    fontSize: 9, // 9sp
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 权益项横向可滑动列表
          if (benefits.isEmpty)
            const Text('暂无权益', style: AppTextStyles.bodySmall)
          else
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: benefits.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _BenefitSlot(
                    benefit: benefits[index],
                    index: index,
                    onTap: onClaimTap,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _BenefitSlot extends StatelessWidget {
  final HomeMonthlyBenefit benefit;
  final int index;
  final ValueChanged<HomeMonthlyBenefit>? onTap;

  const _BenefitSlot({required this.benefit, required this.index, this.onTap});

  @override
  Widget build(BuildContext context) {
    // 对应 quanyi_0.png ~ quanyi_5.png 本地资源路径
    final assetPath = 'assets/images/home/quanyi_${index % 6}.png';
    final imageUrl = (benefit.imageUrl != null && benefit.imageUrl!.isNotEmpty)
        ? benefit.imageUrl!
        : assetPath;

    return GestureDetector(
      onTap: () => onTap?.call(benefit),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52, // 固定的权益槽宽度
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 52x52 权益图片
            SizedBox(
              width: 52,
              height: 52,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppNetworkImage(
                  url: imageUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorWidget: Image.asset(
                    assetPath,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFFFF0ED),
                      child: const Center(child: Icon(Icons.stars, size: 24, color: Color(0xFFFB9126))),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // 橙色胶囊 "领取" 按钮 (37dp x 17dp, #fffb9126 背景, 9sp 白色字)
            Container(
              width: 37,
              height: 17,
              decoration: BoxDecoration(
                color: const Color(0xFFFB9126), // #fffb9126 橙色填充
                borderRadius: BorderRadius.circular(10), // 胶囊圆角
              ),
              child: const Center(
                child: Text(
                  '领取',
                  style: TextStyle(
                    fontSize: 9, // 9sp 文字
                    color: Colors.white, // #ffffffff 白色
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
