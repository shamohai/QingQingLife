import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// 列表设置项数据
class SettingItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const SettingItem({required this.icon, required this.title, this.subtitle, this.onTap});
}

/// 列表设置组件
class SettingsList extends StatelessWidget {
  final List<SettingItem> items;

  const SettingsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(item.icon, color: AppColors.primary, size: 22),
                  title: Text(item.title, style: const TextStyle(fontSize: 15)),
                  subtitle: item.subtitle != null ? Text(item.subtitle!, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)) : null,
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.outline),
                  onTap: item.onTap,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                ),
              ),
              if (!isLast) Divider(height: 1, thickness: 0.5, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }
}