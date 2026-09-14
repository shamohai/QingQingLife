import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 积分余额卡片（白色背景 + 红色到期信息条，向上覆盖 Banner 底部）
class PointsBalanceCard extends StatelessWidget {
  final int currentPoints;
  final int expiringPoints;
  final DateTime expiryDate;
  final VoidCallback? onDetailTap;

  const PointsBalanceCard({
    super.key,
    required this.currentPoints,
    required this.expiringPoints,
    required this.expiryDate,
    this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          const BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expiringPoints > 0)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notification_important,
                    size: 14,
                    color: Color(0xFFFF2105),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '您有$expiringPoints积分将于${expiryDate.year}年${expiryDate.month}月${expiryDate.day}日到期',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFF2105),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                NumberFormat('#,##0').format(currentPoints),
                style: AppTextStyles.headlineLarge.copyWith(
                  color: const Color(0xFF090909),
                  fontSize: 32,
                  height: 1.1,
                  letterSpacing: -1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '积分余额',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDetailTap,
                child: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.outline,
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: onDetailTap,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: const StadiumBorder(),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '积分明细',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
