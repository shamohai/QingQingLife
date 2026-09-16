import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty.dart';
import 'points_product_row.dart';
import '../../data/models/points_mall_home_data.dart';

/// 积分商城右侧商品列表面板
class PointsProductListPanel extends StatelessWidget {
  final List<PointsProduct> products;
  final void Function(PointsProduct)? onExchange;

  const PointsProductListPanel({super.key, required this.products, this.onExchange});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: AppEmpty(message: '该分类暂无商品'),
      );
    }

  return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      // 列表四周的留白全部交给外部的 padding 控制（比如上下左右都是 10）
      padding: const EdgeInsets.all(10),
      // 每个元素之间塞一个高为 10 的透明方块
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => PointsProductRow(product: products[index], onExchange: onExchange != null ? () => onExchange!(products[index]) : null),
    );
  }
}
