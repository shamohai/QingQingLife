import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty.dart';
import 'points_product_row.dart';
import '../../data/models/points_mall_home_data.dart';

/// 积分商城右侧商品列表面板
class PointsProductListPanel extends StatelessWidget {
  final List<PointsProduct> products;
  final void Function(PointsProduct)? onExchange;
  final void Function(PointsProduct)? onServiceTap;

  const PointsProductListPanel({super.key, required this.products, this.onExchange, this.onServiceTap});

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
      padding: const EdgeInsets.all(10),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = products[index];
        final isService = product.type.name == 'service';
        // debugPrint('[ListPanel] id=${product.id} type=${product.type} name=${product.type.name} isService=$isService');
        return PointsProductRow(
          product: product,
          onExchange: onExchange != null ? () => onExchange!(product) : null,
          onServiceTap: isService && onServiceTap != null ? () => onServiceTap!(product) : null,
        );
      },
    );
  }
}
