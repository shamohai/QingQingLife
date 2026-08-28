import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/presentation/paging/paging_list_view.dart';
import '../providers/home_paging_providers.dart';
import 'home_product_card.dart';

/// 热卖商品横向滚动列表（支持分页加载更多）
class HomeHotProducts extends ConsumerWidget {
  const HomeHotProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('热卖商品', style: AppTextStyles.headlineSmall),
              Consumer(
                builder: (context, ref, _) {
                  final pagingData = ref.watch(homeHotProductsProvider);
                  if (!pagingData.hasMore && pagingData.items.isNotEmpty) {
                    return TextButton(
                      onPressed: () {},
                      child: Text(
                        '已加载全部',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    );
                  }
                  return TextButton(
                    onPressed: pagingData.isLoading
                        ? null
                        : () => ref.read(homeHotProductsProvider.notifier).loadMore(),
                    child: Text('查看更多', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 220,
          child: PagingListView<ProductCard>(
            provider: homeHotProductsProvider,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, product, index) => HomeProductCard(product: product),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: const SizedBox(width: AppSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            enablePullToRefresh: false, // 横向列表禁用下拉刷新
          ),
        ),
      ],
    );
  }
}
