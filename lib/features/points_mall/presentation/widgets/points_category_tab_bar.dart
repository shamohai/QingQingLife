import 'package:flutter/material.dart';

import '../../data/models/points_mall_home_data.dart';

/// 积分商城分类 Tab 栏（水平可滚动，sticky 钉住）
class PointsCategoryTabBar extends StatelessWidget {
  final List<PointsCategory> categories;
  final String activeCategoryId;
  final ValueChanged<String> onCategoryTap;

  const PointsCategoryTabBar({super.key, required this.categories, required this.activeCategoryId, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(9), topRight: Radius.circular(9)),
      ),
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 22), // 适当拉开分类间距
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = category.id == activeCategoryId;
          return GestureDetector(
            onTap: () => onCategoryTap(category.id),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.only(bottom: 4), // 设置文字与横线的间隙
                decoration: isActive
                    ? const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF213775), width: 3)),
                      )
                    : null,
                child: Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 14,
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
