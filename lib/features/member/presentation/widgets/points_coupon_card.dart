import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/user_profile_provider.dart';

class PointsCouponCard extends ConsumerWidget {
  const PointsCouponCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileProvider);
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      state.points.toString(),
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text('积分', style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              Container(height: 36, width: 1, color: AppColors.divider),
              Expanded(
                child: Column(
                  children: [
                    Text(state.couponCount.toString(), style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 2),
                    Text('卡券', style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (state.expiringPoints != null && state.expiringPoints! > 0) _ExpiryNotice(expiringPoints: state.expiringPoints!, expiringDate: state.expiringDate),
      ],
    );
  }
}

class _ExpiryNotice extends StatelessWidget {
  final int expiringPoints;
  final DateTime? expiringDate;
  const _ExpiryNotice({required this.expiringPoints, this.expiringDate});

  @override
  Widget build(BuildContext context) {
    final String dateStr;
    if (expiringDate != null) {
      dateStr = '${expiringDate!.year}年${expiringDate!.month}月${expiringDate!.day}日';
    } else {
      dateStr = '2026年12月31日';
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: Text('您有${expiringPoints}积分将于${dateStr}到期', style: const TextStyle(fontSize: 20, color: Color(0xFF666666))),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              '立即使用',
              style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
