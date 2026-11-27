import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';
import '../../../points/mall/presentation/utils/butler_mini_program_launcher.dart';

/// 服务中心右下角悬浮按钮组
///
/// - 左下角：「预约记录」40x40 蓝色圆角按钮，点击跳转服务记录页
/// - 右下角：管家服务，点击打开微信小程序
class ServiceFloatingButtons extends ConsumerWidget {
  final VoidCallback? onServiceTap;

  const ServiceFloatingButtons({super.key, this.onServiceTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // 左下：预约记录 40x40
        Positioned(
          left: AppSpacing.lg,
          bottom: 20,
          child: _FloatButton(label: '预约\n记录', onTap: () => context.push(RouteNames.serviceRecords)),
        ),
        // 右下：管家服务
        Positioned(
          right: AppSpacing.lg,
          bottom: 20,
          child: _FloatIconButton(
            asset: 'assets/images/points/icon-service.png',
            label: '管家服务',
            iconSize: 20, // 管家服务图填充较大，稍小一点保持视觉平衡
            onTap: onServiceTap ?? () => launchButlerMiniProgram(context, ref),
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
        width: 56,
        height: 56,
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
  final String? asset;
  final IconData? icon;
  final String label;
  final double iconSize;
  final VoidCallback? onTap;

  const _FloatIconButton({this.asset, this.icon, required this.label, this.iconSize = 20, this.onTap}) : assert(asset != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.serviceFloatBg, shape: BoxShape.circle
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            asset != null ? Image.asset(asset!, width: iconSize, height: iconSize, color: Colors.white) : Icon(icon, color: Colors.white, size: iconSize),
            const SizedBox(height: 2),
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
