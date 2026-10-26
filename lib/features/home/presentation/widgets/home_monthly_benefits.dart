import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/widgets/app_image.dart';

/// 每月权益展示卡片（支持横向滑动，对齐蓝湖设计规范）
class HomeMonthlyBenefits extends StatelessWidget {
  final List<HomeMonthlyBenefit> benefits;
  final Set<String> claimingIds;
  final int activeUserServiceId; // 当前当月激活的 userServiceId（>0 表示已领取）
  final bool isReceived; // 当月权益优惠券是否已领取
  final bool settlemented; // 是否已发货\已兑换\已核销
  final ValueChanged<HomeMonthlyBenefit>? onImageTap;
  final ValueChanged<HomeMonthlyBenefit>? onClaimTap;

  const HomeMonthlyBenefits({
    super.key,
    required this.benefits,
    this.claimingIds = const {},
    this.activeUserServiceId = 0,
    this.isReceived = false,
    this.settlemented = false,
    this.onImageTap,
    this.onClaimTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 24,
                  height: 24,
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
                  final benefit = benefits[index];
                  // 判断每个 item 的有效 userServiceId、isClaimed 和 isSettlemented 状态
                  final effectiveUserServiceId = activeUserServiceId > 0 ? activeUserServiceId : benefit.userServiceId;
                  final effectiveIsClaimed = effectiveUserServiceId > 0 || isReceived || benefit.isReceived;
                  final effectiveSettlemented = settlemented || benefit.settlemented;
                  final isClaiming = claimingIds.contains(benefit.id);

                  return _BenefitSlot(
                    benefit: benefit,
                    index: index,
                    userServiceId: effectiveUserServiceId,
                    isClaimed: effectiveIsClaimed,
                    isSettlemented: effectiveSettlemented,
                    isClaiming: isClaiming,
                    onImageTap: onImageTap,
                    onClaimTap: onClaimTap,
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
  final int userServiceId;
  final bool isClaimed;
  final bool isSettlemented;
  final bool isClaiming;
  final ValueChanged<HomeMonthlyBenefit>? onImageTap;
  final ValueChanged<HomeMonthlyBenefit>? onClaimTap;

  const _BenefitSlot({
    required this.benefit,
    required this.index,
    required this.userServiceId,
    required this.isClaimed,
    required this.isSettlemented,
    required this.isClaiming,
    this.onImageTap,
    this.onClaimTap,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = 'assets/images/home/quanyi_${index % 6}.png';
    final imageUrl = (benefit.imageUrl != null && benefit.imageUrl!.isNotEmpty) ? benefit.imageUrl! : assetPath;

    // 状态 1: !isClaimed (当月未领取) -> 按钮"领取"
    // 状态 2: isClaimed 且 !isSettlemented (当月已领取未兑换/未核销) -> 按钮"去兑换"
    // 状态 3: isClaimed 且 isSettlemented (当月已发货/已兑换/已核销) -> 按钮"已兑换"（不可点击）
    final String buttonText;
    final Color buttonBgColor;
    final bool buttonDisabled;

    if (isClaiming) {
      buttonText = '处理中';
      buttonBgColor = const Color(0xFFC9CDD4);
      buttonDisabled = true;
    } else if (isClaimed && isSettlemented) {
      buttonText = '已兑换';
      buttonBgColor = const Color(0xFFC9CDD4);
      buttonDisabled = true;
    } else if (isClaimed && !isSettlemented) {
      buttonText = '去兑换';
      buttonBgColor = const Color(0xFFFB9126);
      buttonDisabled = false;
    } else {
      buttonText = '领取';
      buttonBgColor = const Color(0xFFFB9126);
      buttonDisabled = false;
    }

    return SizedBox(
      width: 52,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 52x52 权益图片
          GestureDetector(
            onTap: () => onImageTap?.call(benefit),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
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
          ),
          const SizedBox(height: 6),
          // 胶囊按钮
          GestureDetector(
            onTap: buttonDisabled ? null : () => onClaimTap?.call(benefit),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 50,
              height: 20,
              decoration: BoxDecoration(color: buttonBgColor, borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
