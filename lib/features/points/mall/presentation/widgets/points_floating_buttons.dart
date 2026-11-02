import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

/// 积分商城及首页右下角浮动操作按钮组（使用蓝湖切图）
class PointsFloatingButtons extends StatelessWidget {
  static const _miniProgramUsername = 'gh_c55d2ab30511';
  static const _miniProgramPath = 'pages/group/join?from=app';

  final VoidCallback? onCartTap;
  final VoidCallback? onServiceTap;

  const PointsFloatingButtons({super.key, this.onCartTap, this.onServiceTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // _FloatingButton(
        //   asset: 'assets/images/points/icon-cart.png',
        //   label: '购物车',
        //   iconSize: 32,
        //   onTap: onCartTap ?? () => context.push(RouteNames.cart),
        // ),
        const SizedBox(height: 12),
        _FloatingButton(
          asset: 'assets/images/points/icon-service.png',
          label: '管家服务',
          iconSize: 20,
          onTap: onServiceTap ?? () => _openButlerMiniProgram(context),
        ),
      ],
    );
  }

  Future<void> _openButlerMiniProgram(BuildContext context) async {
    try {
      final weChat = fluwx.Fluwx();
      final isInstalled = await weChat.isWeChatInstalled;
      if (!context.mounted) return;

      if (!isInstalled) {
        _showMessage(context, '请先安装微信后再使用管家服务');
        return;
      }

      await weChat.open(
        target: fluwx.MiniProgram(username: _miniProgramUsername, path: _miniProgramPath),
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
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 1),
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
