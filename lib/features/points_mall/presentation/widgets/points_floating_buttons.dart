import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// 积分商城右下角浮动操作按钮组（使用蓝湖切图）
class PointsFloatingButtons extends StatelessWidget {
  const PointsFloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FloatingButton(asset: 'assets/images/points/icon-cart.png', label: '购物车'),
        const SizedBox(height: AppSpacing.md),
        _FloatingButton(icon: Icons.headset, label: '管家服务'),
      ],
    );
  }
}

class _FloatingButton extends StatelessWidget {
  final String? asset;
  final IconData? icon;
  final String label;

  const _FloatingButton({this.asset, this.icon, required this.label}) : assert(asset != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          asset != null ? Image.asset(asset!, width: 22, height: 22, color: Colors.white) : Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 2),
          // 文字（也在圆形内部）
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: Colors.white, height: 1.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
