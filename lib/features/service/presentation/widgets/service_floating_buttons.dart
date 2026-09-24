import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';

/// 服务中心右下角悬浮按钮组
///
/// - 左下角：「预约记录」40x40 蓝色圆角按钮，点击跳转服务记录页
/// - 右下角：购物车 29x30 + 客服 29x30，竖向排列
class ServiceFloatingButtons extends StatelessWidget {
  const ServiceFloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        // 左下：预约记录 40x40
        Positioned(
          left: AppSpacing.lg,
          bottom: bottomInset + AppSpacing.lg,
          child: _FloatButton(label: '预约\n记录', onTap: () => context.push(RouteNames.serviceRecords)),
        ),
        // 右下：购物车 + 客服 29x30
        Positioned(
          right: AppSpacing.lg,
          bottom: bottomInset + AppSpacing.lg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FloatIconButton(icon: Icons.shopping_cart, onTap: () => context.push(RouteNames.serviceCart)),
              const SizedBox(height: 8),
              _FloatIconButton(icon: Icons.headset, onTap: () => context.push(RouteNames.customerService)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FloatButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FloatButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: AppColors.serviceFloatBg, shape: BoxShape.circle),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white, height: 1.1),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _FloatIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FloatIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 29,
        height: 30,
        decoration: BoxDecoration(color: AppColors.serviceFloatBg, borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, size: 17, color: Colors.white),
      ),
    );
  }
}
