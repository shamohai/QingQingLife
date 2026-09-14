import 'package:flutter/material.dart';

import '../../data/models/points_mall_home_data.dart';
import 'points_category_sidebar.dart';
import 'points_product_list_panel.dart';

/// 积分商城双栏商品区域（左侧分类侧边栏 + 右侧商品列表）
class TwoPanelProductSection extends StatefulWidget {
  final List<PointsRedeemGroup> groups;
  final void Function(PointsProduct)? onExchange;

  const TwoPanelProductSection({
    super.key,
    required this.groups,
    this.onExchange,
  });

  @override
  State<TwoPanelProductSection> createState() => _TwoPanelProductSectionState();
}

class _TwoPanelProductSectionState extends State<TwoPanelProductSection> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F5F7),
      child: Row(
        children: [
          Flexible(
            flex: 0,
            child: PointsCategorySidebar(
              groups: widget.groups,
              activeIndex: _activeIndex,
              onCategoryTap: (index) => setState(() => _activeIndex = index),
            ),
          ),
          const VerticalDivider(width: 1, color: Color(0xFFE1E4DC)),
          Expanded(
            child: PointsProductListPanel(
              products: widget.groups[_activeIndex].products,
              onExchange: widget.onExchange,
            ),
          ),
        ],
      ),
    );
  }
}
