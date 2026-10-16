import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
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
          width: 32,
          height: 32,
          onTap: onCartTap ?? () => context.push(RouteNames.cart),
        ),
        const SizedBox(height: AppSpacing.md),
        _FloatingButton(asset: 'assets/images/points/icon-service.png', label: '管家服务', onTap: onServiceTap ?? () => context.push(RouteNames.customerService)),
      ],
    );
  }
}

class _FloatingButton extends StatelessWidget {
  final String? asset;
  final IconData? icon;
  final String label;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const _FloatingButton({this.asset, this.icon, required this.label, this.width, this.height, this.onTap}) : assert(asset != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 1, // 白色边框
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            asset != null ? Image.asset(asset!, width: width ?? 22, height: height ?? 22, color: Colors.white) : Icon(icon, color: Colors.white, size: 20),
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
      ),
    );
  }
}
