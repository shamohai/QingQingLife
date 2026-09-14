import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/points_mall_home_data.dart';

/// 积分商城左侧分类侧边栏（固定宽度，选中项有蓝色竖线指示）
class PointsCategorySidebar extends StatefulWidget {
  final List<PointsRedeemGroup> groups;
  final int activeIndex;
  final ValueChanged<int> onCategoryTap;

  const PointsCategorySidebar({
    super.key,
    required this.groups,
    required this.activeIndex,
    required this.onCategoryTap,
  });

  @override
  State<PointsCategorySidebar> createState() => _PointsCategorySidebarState();
}

class _PointsCategorySidebarState extends State<PointsCategorySidebar> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      color: Colors.white,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 12, bottom: 8),
            child: Text(
              '我能兑换',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          ...widget.groups.asMap().entries.map((entry) {
            final index = entry.key;
            final group = entry.value;
            final isActive = index == widget.activeIndex;
            return GestureDetector(
              onTap: () => widget.onCategoryTap(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFF0F4FF) : null,
                ),
                child: Row(
                  children: [
                    if (isActive)
                      Container(
                        width: 2,
                        height: 20,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.all(Radius.circular(1)),
                        ),
                      ),
                    Text(
                      group.rangeLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF090909),
                      ).copyWith(
                        color: isActive ? AppColors.primary : const Color(0xFF090909),
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
