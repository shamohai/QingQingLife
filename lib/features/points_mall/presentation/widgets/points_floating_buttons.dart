import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';

/// 积分商城及首页右下角浮动操作按钮组（使用蓝湖切图）
class PointsFloatingButtons extends StatelessWidget {
  final VoidCallback? onCartTap;
  final VoidCallback? onServiceTap;

  const PointsFloatingButtons({super.key, this.onCartTap, this.onServiceTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FloatingButton(
          asset: 'assets/images/points/icon-cart.png',
          label: '购物车',
          iconSize: 32, // 购物车图本身比较小，稍微放大一点
          onTap: onCartTap ?? () => context.push(RouteNames.cart),
        ),
        const SizedBox(height: 12),
        _FloatingButton(
          asset: 'assets/images/points/icon-service.png',
          label: '管家服务',
          iconSize: 20, // 管家服务图填充较大，稍小一点保持视觉平衡
          onTap: onServiceTap ?? () => context.push(RouteNames.customerService),
        ),
      ],
    );
  }
}

class _FloatingButton extends StatelessWidget {
  final String? asset;
  final IconData? icon;
  final String label;
  final double iconSize;
  final VoidCallback? onTap;

  const _FloatingButton({this.asset, this.icon, required this.label, this.iconSize = 20, this.onTap}) : assert(asset != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28), // 56/2 = 28，完美圆形
          border: Border.all(
            color: Colors.white,
            width: 1, // 稍微加粗一点，白边更清晰
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            asset != null ? Image.asset(asset!, width: iconSize, height: iconSize, color: Colors.white) : Icon(icon, color: Colors.white, size: iconSize),
            const SizedBox(height: 2),
            // 文字
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: Colors.white, height: 1.0, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
