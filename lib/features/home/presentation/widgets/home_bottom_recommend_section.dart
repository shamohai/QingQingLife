import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../points_mall/data/models/get_credit_product_list_model.dart';
import '../providers/home_paging_providers.dart';

/// 首页底部推荐展示区（模块 1 元宝卡片 + 动态青稞粒商品错落列表 + 底部 bottom.png）
class HomeBottomRecommendSection extends ConsumerWidget {
  const HomeBottomRecommendSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagingData = ref.watch(homeRecommendCreditProductsProvider);

    if (pagingData.status == PagingStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(homeRecommendCreditProductsProvider.notifier).loadFirstPage();
      });
    }

    final items = pagingData.items;

    // 分离左右两列元素
    final leftCards = <Widget>[];
    final rightCards = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final card = _ProductCard(product: items[i]);
      if (i % 2 == 0) {
        leftCards.add(card);
      } else {
        rightCards.add(card);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧列：模块 1（元宝专区图片卡片） + 偶数索引商品
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 模块 1：元宝图片卡片 (白色背景，圆角 14px)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/home/yuanbao.png',
                      fit: BoxFit.cover,
                      height: 180,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: const Color(0xFFF5F5F5),
                        child: const Center(
                          child: Text('元宝专区', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  for (final card in leftCards) ...[
                    const SizedBox(height: 12),
                    card,
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 右侧列：奇数索引商品
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < rightCards.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    rightCards[i],
                  ],
                ],
              ),
            ),
          ],
        ),

        // 底部加载状态指示
        if (pagingData.isLoading) ...[
          const SizedBox(height: 20),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
            ),
          ),
        ],

        // 错误重试指示
        if (pagingData.isError && items.isEmpty) ...[
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: () => ref.read(homeRecommendCreditProductsProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
              label: const Text('加载失败，点击重试', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],

        const SizedBox(height: 30),

        // 底部居中的 bottom.png (67x20) 及下箭头，整体水平居中
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/home/bottom.png',
                width: 67,
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 4),
              if (!pagingData.hasMore && items.isNotEmpty)
                const Text(
                  '没有更多了',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                )
              else
                const SizedBox(
                  width: 24,
                  height: 14,
                  child: Icon(Icons.keyboard_arrow_down, size: 24, color: Colors.white),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final CreditProductItem product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          // 点击跳转积分商品详情页
          context.push(
            RouteNames.serviceProductDetail.replaceFirst(':id', '${product.productId}'),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 商品图片，圆角 9dp
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: AppNetworkImage(
                url: product.imgUrl,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
                errorWidget: Container(
                  height: 140,
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // 会员价/积分专享标签 + 商品名称（2行）
            Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: const EdgeInsets.only(right: 4, bottom: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF213775), // 同 Home 藏青色背景 #213775
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        product.isCredit ? '积分专享' : '会员价',
                        style: const TextStyle(
                          color: Color(0xFFD7B480), // 金色文字
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  TextSpan(
                    text: product.productName,
                    style: const TextStyle(color: Color(0xFF000000), fontSize: 11, height: 1.25),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // 提示信息标签（如有）
            if (product.warning != null && product.warning!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD9D9D9), width: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.warning!,
                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            // 积分/价格与购物车行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${product.creditPrice}',
                        style: const TextStyle(
                          color: Color(0xFFFF2105),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        '积分',
                        style: TextStyle(
                          color: Color(0xFFFF2105),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/home/cart_red.png',
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.shopping_cart, size: 16, color: Color(0xFFFF2105)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
