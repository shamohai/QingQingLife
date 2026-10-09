import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

/// 页脚：退出登录按钮（白色圆角通栏 + 退出图标）
class ProfileFooter extends ConsumerWidget {
  const ProfileFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xl),
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context, ref),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))],
          ),
          alignment: Alignment.center,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '退出登录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C)),
              ),
              SizedBox(width: 8),
              Icon(Icons.logout, size: 18, color: Color(0xFF1A1D1C)),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}
