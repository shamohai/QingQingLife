import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';
import '../../../../../features/points/mall/presentation/providers/butler_mini_program_provider.dart';

/// 服务中心右下角悬浮按钮组
///
/// - 左下角：「预约记录」40x40 蓝色圆角按钮，点击跳转服务记录页
/// - 右下角：管家服务，点击打开微信小程序
class ServiceFloatingButtons extends ConsumerWidget {
  static const _miniProgramUsername = 'gh_c55d2ab30511';

  final VoidCallback? onServiceTap;

  const ServiceFloatingButtons({super.key, this.onServiceTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        // 左下：预约记录 40x40
        Positioned(
          left: AppSpacing.lg,
          bottom: bottomInset + AppSpacing.lg,
          child: _FloatButton(label: '预约\n记录', onTap: () => context.push(RouteNames.serviceRecords)),
        ),
        // 右下：管家服务
        Positioned(
          right: AppSpacing.lg,
          bottom: bottomInset + AppSpacing.lg,
          child: _FloatIconButton(
            asset: 'assets/images/points/icon-service.png',
            label: '管家服务',
            iconSize: 18, // 管家服务图填充较大，稍小一点保持视觉平衡
            onTap: onServiceTap ?? () => _openButlerMiniProgram(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _openButlerMiniProgram(BuildContext context, WidgetRef ref) async {
    try {
      final info = await ref.read(butlerMiniProgramInfoProvider.future);
      if (!context.mounted) return;
      final path = info?.workwxmppath.trim() ?? '';
      if (path.isEmpty) {
        _showMessage(context, '暂无法获取管家服务入口，请稍后重试');
        return;
      }

      final weChat = fluwx.Fluwx();
      final isInstalled = await weChat.isWeChatInstalled;
      if (!context.mounted) return;

      if (!isInstalled) {
        _showMessage(context, '请先安装微信后再使用管家服务');
        return;
      }

      await weChat.open(
        target: fluwx.MiniProgram(username: _miniProgramUsername, path: path),
      );
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, '打开管家服务失败，请稍后重试');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: 1, // 稍微加粗一点，白边更清晰
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            if (asset != null)
              Image.asset(asset!, width: iconSize, height: iconSize, color: Colors.white)
            else if (icon != null)
              Icon(icon, color: Colors.white, size: iconSize)
            else
              const SizedBox.shrink(),
            const SizedBox(height: 2),
            // 文字
            Text(
              label,
              style: const TextStyle(fontSize: 6, color: Colors.white, height: 1.0, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
