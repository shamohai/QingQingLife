import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 首页顶部栏：首页标题 + 搜索框 + 消息按钮
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final VoidCallback? onMessagesTap;
  final ValueChanged<String>? onSearch;

  const HomeAppBar({super.key, this.searchController, this.onMessagesTap, this.onSearch});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                '首页',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: '搜索青稞酒、牛肉干...',
                      hintStyle: AppTextStyles.bodySmall,
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.outline),
                      suffixIcon: TextButton(
                        onPressed: () {
                          final text = searchController?.text ?? '';
                          if (text.isNotEmpty && onSearch != null) onSearch!(text);
                        },
                        child: Text('搜索', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                onPressed: onMessagesTap,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}