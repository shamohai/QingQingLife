import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/points_mall_paging_providers.dart';
import '../widgets/points_balance_card.dart';
import '../widgets/points_mall_header.dart';
import '../widgets/points_product_card.dart';

class PointsMallPage extends ConsumerWidget {
  const PointsMallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staticDataAsync = ref.watch(pointsMallStaticDataProvider);

    return Scaffold(
      body: staticDataAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stackTrace) => Center(
          child: AppError(message: '加载失败: $error', onRetry: () => ref.invalidate(pointsMallStaticDataProvider)),
        ),
        data: (staticData) => CustomScrollView(
          slivers: [
            SliverSafeArea(
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    PointsBalanceCard(
                      currentPoints: staticData.currentPoints,
                      expiringPoints: staticData.expiringPoints,
                      expiryDate: staticData.expiryDate,
                      rulesText: staticData.rulesText,
                    ),
                    PointsMallHeader(
                      bannerUrl: staticData.bannerUrl,
                      categories: staticData.categories,
                      rulesText: staticData.rulesText,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text('积分兑换', style: AppTextStyles.headlineSmall),
              ),
            ),
            Consumer(
              builder: (context, ref, _) {
                final productsData = ref.watch(pointsMallProductListProvider);

                if (productsData.status == PagingStatus.loading && productsData.items.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: AppSpacing.md),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (productsData.status == PagingStatus.error && productsData.items.isEmpty) {
                  return SliverToBoxAdapter(child: Center(child: Text('加载失败: ${productsData.errorMessage}')));
                }

                if (productsData.items.isEmpty) {
                  return const SliverToBoxAdapter(child: AppEmpty(message: '暂无商品'));
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == productsData.items.length) {
                          return _buildFooter(ref, productsData);
                        }
                        return PointsProductCard(product: productsData.items[index]);
                      },
                      childCount: productsData.items.length + (productsData.hasMore ? 1 : 0),
                    ),
                  ),
                );
              },
            ),
            SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.xxxl)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(WidgetRef ref, PagingData pagingData) {
    if (pagingData.status == PagingStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (pagingData.hasMore) {
      return Center(
        child: TextButton(
          onPressed: () => ref.read(pointsMallProductListProvider.notifier).loadMore(),
          child: const Text('加载更多'),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
