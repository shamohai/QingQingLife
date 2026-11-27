import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../../points/mall/data/models/get_recommend_product_list_model.dart';
import '../providers/home_paging_providers.dart';
import 'home_credit_product_card.dart';

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
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(AppRadius.md))),
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
                  Text('热门兑换', style: AppTextStyles.headlineSmall),
                ],
              ),
              // GestureDetector(
              //   onTap: () {
              //     final pagingData = ref.read(homeHotProductsProvider);
              //     if (!pagingData.isLoading && pagingData.hasMore) {
              //       ref.read(homeHotProductsProvider.notifier).loadMore();
              //     }
              //   },
              //   child: const Text(
              //     '查看全部>>>',
              //     style: TextStyle(
              //       color: Color(0xFF8E8E93), // #ff8e8e93 文字颜色
              //       fontSize: 9, // 9sp 文字大小
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Consumer(
            builder: (context, ref, child) {
              final pagingData = ref.watch(homeHotProductsProvider);
              if (pagingData.status == PagingStatus.initial) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    ref.read(homeHotProductsProvider.notifier).loadFirstPage();
                  }
                });
              }

              if (pagingData.isLoading && pagingData.items.isEmpty) {
                return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
              }
              if (pagingData.isError && pagingData.items.isEmpty) {
                return SizedBox(height: 60, child: Center(child: Text(pagingData.errorMessage ?? '加载失败')));
              }
              if (pagingData.items.isEmpty) {
                return const SizedBox(height: 60, child: Center(child: Text('暂无数据')));
              }

              return HotProductsStrip(items: pagingData.items);
            },
          ),
        ],
      ),
    );
  }
}

/// 横向商品列表。
///
/// 使用 SingleChildScrollView(横向) + Row：高度由卡片真实布局决定，
/// 不写死高度，也不做运行时测量，因此字体缩放与不同平台下都不会溢出或留白。
/// 数据量每页约 10 条，一次性构建的开销可以接受。
class HotProductsStrip extends StatelessWidget {
  final List<CreditMallProduct> items;

  const HotProductsStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () => context.push(RouteNames.serviceProductDetail.replaceFirst(':id', '${items[i].productId}')),
              child: HomeCreditProductCard(product: items[i]),
            ),
          ],
        ],
      ),
    );
  }
}
