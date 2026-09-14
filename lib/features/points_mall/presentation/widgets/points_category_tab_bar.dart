import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';

/// 积分商城分类 Tab 栏（水平可滚动，sticky 钉住）
class PointsCategoryTabBar extends StatelessWidget {
  final List<String> categories;
  final String activeCategoryId;
  final ValueChanged<String> onCategoryTap;

  const PointsCategoryTabBar({
    super.key,
    required this.categories,
    required this.activeCategoryId,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(9),
          topRight: Radius.circular(9),
        ),
      ),
      height: 37,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20), // 适当拉开分类间距
        itemBuilder: (context, index) {
          final label = categories[index];
          final isActive = label == activeCategoryId;
          return GestureDetector(
            onTap: () => onCategoryTap(label),
            child: Container(
              height: 37,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.only(bottom: 4), // 设置文字与横线的间隙
                decoration: isActive
                    ? const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF213775),
                            width: 3,
                          ),
                        ),
                      )
                    : null,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? const Color(0xFF213775) : const Color(0xFF8E8E93),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
