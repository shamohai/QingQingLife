import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';

/// 积分商城搜索区域（蓝色背景 + 搜索框）
/// 作为 CustomScrollView 的内容区的一部分，非固定 AppBar
class PointsSearchArea extends StatelessWidget {
  final TextEditingController? searchController;
  final VoidCallback? onSearch;

  const PointsSearchArea({
    super.key,
    this.searchController,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.md,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: TextField(
                controller: searchController,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '搜索心仪好物',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF949599),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: Color(0xFF949599),
                  ),
                  suffixIcon: InkWell(
                    onTap: onSearch,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        '搜索',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => onSearch?.call(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
