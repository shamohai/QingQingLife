import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_spacing.dart';
import 'home_product_card.dart';
import '../providers/home_provider.dart';

/// 商品列表（2列网格）
class HomeProductGrid extends ConsumerWidget {
  const HomeProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.read(homeDataProvider).hotProducts;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.75,
        children: List.generate(products.length, (i) => HomeProductCard(product: products[i])),
      ),
    );
  }
}
