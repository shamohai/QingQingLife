import 'package:flutter/material.dart';

import '../../data/models/points_mall_home_data.dart';
import 'points_category_sidebar.dart';
import 'points_product_list_panel.dart';

/// 积分商城双栏商品区域（左侧分类侧边栏 + 右侧商品列表）
class TwoPanelProductSection extends StatefulWidget {
  final List<PointsRedeemGroup> groups;
  final void Function(PointsProduct)? onExchange;

  const TwoPanelProductSection({super.key, required this.groups, this.onExchange});

  @override
  State<TwoPanelProductSection> createState() => _TwoPanelProductSectionState();
}

class _TwoPanelProductSectionState extends State<TwoPanelProductSection> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 处理 "我能兑换" 逻辑：如果选中第一个，则展示所有组的汇总或第一组
    // 这里简单处理为展示第一组，实际业务可能需要展示所有可兑换商品
    final displayProducts = _activeIndex == 0 ? widget.groups.expand((g) => g.products).toList() : widget.groups[_activeIndex - 1].products;

    return Container(
      color: const Color(0xFFF3F5F7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PointsCategorySidebar(groups: widget.groups, activeIndex: _activeIndex, onCategoryTap: (index) => setState(() => _activeIndex = index)),
          const VerticalDivider(width: 1, color: Color(0xFFE1E4DC)),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 4),
              color: Colors.white, // 右侧商品列表背景改为白色
              child: PointsProductListPanel(products: displayProducts, onExchange: widget.onExchange),
            ),
          ),
        ],
      ),
    );
  }
}
