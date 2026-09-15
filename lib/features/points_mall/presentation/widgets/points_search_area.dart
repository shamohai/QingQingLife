import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';

/// 积分商城搜索区域（白色胶囊 pill，蓝色描边，浮在 Banner 上）
class PointsSearchArea extends StatelessWidget {
  final TextEditingController? searchController;
  final VoidCallback? onSearch;

  const PointsSearchArea({super.key, this.searchController, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md, left: AppSpacing.lg, right: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.round),
                border: Border.all(color: const Color(0xFF213775), width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search, size: 22, color: Color(0xFF949599)),
                  const SizedBox(width: 2),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: '搜索心仪好物',
                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF949599)),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hoverColor: Colors.white,
                        focusColor: Colors.white,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      onSubmitted: (_) => onSearch?.call(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onSearch,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '搜索',
                        style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
