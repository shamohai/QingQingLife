import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../providers/home_paging_providers.dart';
import 'home_product_card.dart';

/// 商品列表（2列网格，支持分页加载更多）
class HomeProductGrid extends ConsumerWidget {
  const HomeProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagingData = ref.watch(homeProductGridProvider);

    if (pagingData.status == PagingStatus.loading && pagingData.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (pagingData.status == PagingStatus.error && pagingData.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('加载失败: .errorMessage'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(homeProductGridProvider.notifier).refresh(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.75,
            ),
            itemCount: pagingData.items.length,
            itemBuilder: (context, index) => HomeProductCard(product: pagingData.items[index]),
          ),
          _buildFooter(context, ref, pagingData),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, PagingData<ProductCard> pagingData) {
    if (pagingData.status == PagingStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: CircularProgressIndicator(),
      );
    }

    if (pagingData.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ElevatedButton(
          onPressed: () => ref.read(homeProductGridProvider.notifier).loadMore(),
          child: const Text('加载更多'),
        ),
      );
    }

    if (pagingData.items.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Text('已经到底了', style: TextStyle(color: Colors.grey, fontSize: 12)),
      );
    }

    return const SizedBox.shrink();
  }
}
