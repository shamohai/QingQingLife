import 'package:flutter/material.dart';

/// 积分段标签（静态配置，第一项为“我能兑换”）
const List<String> kPointsRangeLabels = ['我能兑换', '0~1000', '1001~5000', '5001~10000', '10001~20000', '20000以上'];

/// 积分商城左侧分类侧边栏（固定宽度，选中项有蓝色竖线指示）
class PointsCategorySidebar extends StatefulWidget {
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onCategoryTap;
  final double? height;

  const PointsCategorySidebar({super.key, this.labels = kPointsRangeLabels, required this.activeIndex, required this.onCategoryTap, this.height});

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
    final allLabels = widget.labels;

    return Container(
      width: 120, // 侧边栏容器总宽度
      height: widget.height,
      color: const Color(0xFFF3F5F7),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [for (int index = 0; index < allLabels.length; index++) _buildCategoryItem(allLabels[index], index)],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String label, int index) {
    final isActive = index == widget.activeIndex;
    return GestureDetector(
      onTap: () => widget.onCategoryTap(index),
      child: Container(
        width: 116,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: isActive ? const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6)) : null,
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
                padding: const EdgeInsets.only(right: 6, left: 4),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
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
  }
}
