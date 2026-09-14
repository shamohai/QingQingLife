import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty.dart';
import 'points_product_row.dart';
import '../../data/models/points_mall_home_data.dart';

/// 积分商城右侧商品列表面板
class PointsProductListPanel extends StatelessWidget {
  final List<PointsProduct> products;
  final void Function(PointsProduct)? onExchange;

  const PointsProductListPanel({
    super.key,
    required this.products,
    this.onExchange,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: AppEmpty(message: '该分类暂无商品'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: PointsProductRow(
          product: products[index],
          onExchange: onExchange != null ? () => onExchange!(products[index]) : null,
        ),
      ),
    );
  }
}
