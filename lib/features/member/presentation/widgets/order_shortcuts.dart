import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class OrderShortcutItem {
  final IconData icon;
  final String label;
  final int count;
  const OrderShortcutItem({required this.icon, required this.label, this.count = 0});
}

class OrderShortcuts extends StatelessWidget {
  const OrderShortcuts({super.key});

  static const _items = [
    OrderShortcutItem(icon: Icons.payment_outlined, label: '待付款', count: 2),
    OrderShortcutItem(icon: Icons.shopping_bag_outlined, label: '待发货', count: 0),
    OrderShortcutItem(icon: Icons.local_shipping_outlined, label: '待收货', count: 1),
    OrderShortcutItem(icon: Icons.rate_review_outlined, label: '待评价', count: 0),
    OrderShortcutItem(icon: Icons.assignment_return_outlined, label: '退换/售后', count: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('我的订单', style: AppTextStyles.headlineSmall),
              TextButton(onPressed: () {}, child: Text('全部订单', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary))),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            childAspectRatio: 0.8,
            children: _items.map((item) => _OrderShortcutCell(item: item)).toList(),
          ),
        ],
      ),
    );
  }
}

class _OrderShortcutCell extends StatelessWidget {
  final OrderShortcutItem item;
  const _OrderShortcutCell({required this.item});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Icon(item.icon, size: 22, color: AppColors.primary)),
            if (item.count > 0)
              Positioned(right: 0, top: 0, child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(item.count.toString(), style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              )),
          ],
        ),
        const SizedBox(height: 4),
        Text(item.label, style: AppTextStyles.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}