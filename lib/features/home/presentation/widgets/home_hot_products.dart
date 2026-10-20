import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/presentation/paging/paging_list_view.dart';
import '../providers/home_paging_providers.dart';
import 'home_product_card.dart';

/// 热卖商品横向滚动列表（白色卡片容器）
/// 设计稿：白色卡片，"热卖商品" 标题 + "查看全部"，横向滚动 112x112 图片
class HomeHotProducts extends ConsumerWidget {
  const HomeHotProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5, // 上下边距
        horizontal: 12, // 左右边距
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(14)), // 设计稿 14px 圆角
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/home/kingkong_member.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                      child: const Icon(Icons.local_fire_department, size: 10, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('热卖商品', style: AppTextStyles.headlineSmall),
                ],
              ),
              GestureDetector(
                onTap: () {
                  final pagingData = ref.read(homeHotProductsProvider);
                  if (!pagingData.isLoading && pagingData.hasMore) {
                    ref.read(homeHotProductsProvider.notifier).loadMore();
                  }
                },
                child: const Text(
                  '查看全部>>>',
                  style: TextStyle(
                    color: Color(0xFF8E8E93), // #ff8e8e93 文字颜色
                    fontSize: 9, // 9sp 文字大小
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 190,
            child: PagingListView<ProductCard>(
              provider: homeHotProductsProvider,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, product, index) => HomeProductCard(product: product, compact: true),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: const SizedBox(width: AppSpacing.sm),
              padding: EdgeInsets.zero,
              enablePullToRefresh: false,
              noMoreWidget: const SizedBox.shrink(), // 不显示“没有更多数据了”
            ),
          ),
        ],
      ),
    );
  }
}
