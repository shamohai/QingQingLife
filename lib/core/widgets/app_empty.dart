import 'package:flutter/material.dart';
import '../../app/theme/app_text_styles.dart';

/// 空状态占位组件
class AppEmpty extends StatelessWidget {
  final String message;
  final IconData icon;

  const AppEmpty({
    super.key,
    this.message = '暂无数据',
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}