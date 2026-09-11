import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/points_mall_paging_providers.dart';
import 'points_product_card.dart';

/// 热门兑换商品横向滚动区
class HotProductsSection extends ConsumerWidget {
  const HotProductsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsData = ref.watch(pointsMallHotProductsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text('热门兑换商品', style: AppTextStyles.headlineSmall),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 235,
          child: productsData.when(
            loading: () => const Center(child: AppLoading()),
            error: (_, __) => const SizedBox.shrink(),
            data: (items) {
              if (items.isEmpty) return const AppEmpty(message: '暂无热门商品');
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: items.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : AppSpacing.md),
                  child: SizedBox(
                    width: 150,
                    child: PointsProductCard(product: items[index]),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
