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
    final allLabels = ['我能兑换', ...widget.groups.map((g) => g.rangeLabel)];

    return Container(
      width: 81,
      height: 340,
      color: const Color(0xFFF3F5F7),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 0),
        itemCount: allLabels.length,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final label = allLabels[index];
          final isActive = index == widget.activeIndex;
          return GestureDetector(
            onTap: () => widget.onCategoryTap(index),
            child: Container(
              width: 78,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: isActive
                    ? const BorderRadius.only(
                        topRight: Radius.circular(9),
                        bottomRight: Radius.circular(9),
                      )
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive ? const Color(0xFF213775) : const Color(0xFF090909),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      height: 1.0,
                    ),
                  ),
                  if (isActive)
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 1,
                        height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFF213775),
                          borderRadius: BorderRadius.circular(67),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
