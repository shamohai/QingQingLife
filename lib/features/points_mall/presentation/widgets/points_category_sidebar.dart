import 'package:flutter/material.dart';

import '../../data/models/points_mall_home_data.dart';

/// 积分商城左侧分类侧边栏（固定宽度，选中项有蓝色竖线指示）
class PointsCategorySidebar extends StatefulWidget {
  final List<PointsRedeemGroup> groups;
  final int activeIndex;
  final ValueChanged<int> onCategoryTap;

  const PointsCategorySidebar({super.key, required this.groups, required this.activeIndex, required this.onCategoryTap});

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
      width: 110, // 再次加大侧边栏容器总宽度
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
              width: 106, // 对应加大内部可点选范围宽度
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: isActive ? const BorderRadius.only(topRight: Radius.circular(9), bottomRight: Radius.circular(9)) : null,
              ),
              child: Row(
                children: [
                  // 左侧选中状态蓝色指示竖线
                  Container(
                    width: 1.8,
                    height: 20,
                    margin: const EdgeInsets.only(left: 6),
                    decoration: BoxDecoration(color: isActive ? const Color(0xFF213775) : Colors.transparent, borderRadius: BorderRadius.circular(2)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, left: 6), // 适当拉开左侧竖线和文字之间的空间
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5, // 进一步把积分段和分类字体加大一点，更具可读性
                          color: isActive ? const Color(0xFF213775) : const Color(0xFF090909),
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          height: 1.2,
                        ),
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
