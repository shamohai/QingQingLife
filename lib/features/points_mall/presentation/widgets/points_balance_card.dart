import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 积分余额卡片（白色背景 + 蓝色到期信息条）
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
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expiringPoints > 0)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withAlpha(20),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 12, color: Color(0xFF1976D2)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '您有$expiringPoints积分将于${expiryDate.month}月${expiryDate.day}日到期',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF1976D2)),
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
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '积分余额',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                NumberFormat('#,##0').format(currentPoints),
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.primary,
                  fontSize: 24,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDetailTap,
                child: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.info_outline, size: 14, color: AppColors.outline),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 28,
                child: OutlinedButton(
                  onPressed: onDetailTap,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
