import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'home_product_card.dart';
import '../providers/home_provider.dart';

/// 热卖商品横向滚动列表
class HomeHotProducts extends ConsumerWidget {
  const HomeHotProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.read(homeDataProvider).hotProducts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('热卖商品', style: AppTextStyles.headlineSmall),
              TextButton(onPressed: () {}, child: Text('查看更多', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary))),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: products.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(right: index < products.length - 1 ? AppSpacing.md : 0),
              child: HomeProductCard(product: products[index]),
            ),
          ),
        ),
      ],
    );
  }
}
