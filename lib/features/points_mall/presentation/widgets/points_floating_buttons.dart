import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// 积分商城右下角浮动操作按钮组
class PointsFloatingButtons extends StatelessWidget {
  const PointsFloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FloatingButton(icon: Icons.shopping_cart_outlined, label: '购物车'),
        const SizedBox(height: AppSpacing.md),
        _FloatingButton(icon: Icons.headset, label: '管家服务'),
      ],
    );
  }
}

class _FloatingButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FloatingButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
      ],
    );
  }
}
