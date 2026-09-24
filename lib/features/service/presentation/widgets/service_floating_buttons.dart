import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';

/// 服务中心右下角悬浮按钮组
///
/// - 左下角：「预约记录」圆形按钮（带文字），点击跳转服务记录页
/// - 右下角：购物车图标 + 客服图标，竖向排列
class ServiceFloatingButtons extends StatelessWidget {
  const ServiceFloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        // 左下：预约记录
        Positioned(
          left: AppSpacing.lg,
          bottom: bottomInset + AppSpacing.lg,
          child: _FloatButton(
            label: '预约\n记录',
            onTap: () => context.push(RouteNames.serviceRecords),
          ),
        ),
        // 右下：购物车 + 客服
        Positioned(
          right: AppSpacing.lg,
          bottom: bottomInset + AppSpacing.lg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FloatIconButton(
                icon: Icons.shopping_cart,
                onTap: () => context.push(RouteNames.serviceCart),
              ),
              const SizedBox(height: AppSpacing.md),
              _FloatIconButton(
                icon: Icons.headset,
                onTap: () => context.push(RouteNames.customerService),
              ),
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
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.serviceFloatBg,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.2,
              letterSpacing: 0.5,
            ),
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
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.serviceFloatBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }
}
