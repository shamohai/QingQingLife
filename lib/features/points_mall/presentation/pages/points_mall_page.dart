import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/points_mall_provider.dart';
import '../widgets/points_balance_card.dart';
import '../widgets/points_mall_header.dart';
import '../widgets/points_product_card.dart';

class PointsMallPage extends ConsumerWidget {
  const PointsMallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.read(pointsMallDataProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverSafeArea(
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [const PointsBalanceCard(), const PointsMallHeader()],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text('积分兑换', style: AppTextStyles.headlineSmall),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => PointsProductCard(
                  imageUrl: data.products[index]['imageUrl'] as String,
                  name: data.products[index]['name'] as String,
                  points: data.products[index]['points'] as int,
                  stock: data.products[index]['stock'] as int,
                ),
                childCount: data.products.length,
              ),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}
