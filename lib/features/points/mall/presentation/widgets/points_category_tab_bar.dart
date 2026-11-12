import 'package:flutter/material.dart';

import '../../data/models/credit_product_category_model.dart';

/// 积分商城分类 Tab 栏（水平可滚动，sticky 钉住）
///
/// 数据来自 GetCreditProductCategory 接口，第一项固定为"全部分类"（categoryId=0）。
class PointsCategoryTabBar extends StatelessWidget {
  final List<CreditProductCategory> categories;
  final int activeCategoryId;
  final ValueChanged<int> onCategoryTap;

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
        separatorBuilder: (_, _) => const SizedBox(width: 22),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = category.categoryId == activeCategoryId;
          return GestureDetector(
            onTap: () => onCategoryTap(category.categoryId),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.only(bottom: 4),
                decoration: isActive
                    ? const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF213775), width: 3)),
                      )
                    : null,
                child: Text(
                  category.categoryName,
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
