import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class KingKongItem {
  final IconData icon;
  final String label;
  final Color? bgColor;
  const KingKongItem({required this.icon, required this.label, this.bgColor});
}

class MemberKingKong extends StatelessWidget {
  const MemberKingKong({super.key});

  static const _items = [
    KingKongItem(icon: Icons.card_giftcard, label: '优惠券', bgColor: AppColors.primaryContainer),
    KingKongItem(icon: Icons.stars, label: '积分', bgColor: const Color(0xFFFFF3E0)),
    KingKongItem(icon: Icons.event, label: '活动', bgColor: const Color(0xFFF3E5F5)),
    KingKongItem(icon: Icons.support_agent, label: '专属管家', bgColor: const Color(0xFFE8F5E9)),
    KingKongItem(icon: Icons.location_on_outlined, label: '地址', bgColor: const Color(0xFFE3F2FD)),
    KingKongItem(icon: Icons.headset, label: '客服', bgColor: const Color(0xFFFFF8E1)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _items.map((item) => _KingKongCell(item: item)).toList(),
      ),
    );
  }
}

class _KingKongCell extends StatelessWidget {
  final KingKongItem item;
  const _KingKongCell({required this.item});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - AppSpacing.lg * 2 - AppSpacing.md * 2 - AppSpacing.sm * 5) / 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.bgColor ?? AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(item.icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(item.label, style: AppTextStyles.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}