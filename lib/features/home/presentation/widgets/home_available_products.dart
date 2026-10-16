import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_image.dart';

/// 可用商品横向展示（4列固定）
/// 设计稿：112x112 图片，"自营" 蓝色标签，名称，价格
class HomeAvailableProducts extends StatelessWidget {
  final List<ProductCard> products;
  final VoidCallback? onManageServiceTap;

  const HomeAvailableProducts({super.key, required this.products, this.onManageServiceTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/home/kingkong_member.png',
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                    child: const Icon(Icons.shopping_bag_outlined, size: 10, color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('可用商品', style: AppTextStyles.headlineSmall),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: Text('查看更多>>>', style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF999999))),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // 商品列表
        SizedBox(
          height: 180,
          child: products.isEmpty
              ? const Center(child: Text('暂无可用商品', style: AppTextStyles.bodySmall))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length > 4 ? 4 : products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Padding(
                      padding: EdgeInsets.only(right: index < (products.length > 4 ? 4 : products.length) - 1 ? AppSpacing.md : 0),
                      child: _AvailableProductCard(product: product),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AvailableProductCard extends StatelessWidget {
  final ProductCard product;

  const _AvailableProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112, // 设计稿 112px 宽度
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片 112x112
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppNetworkImage(url: product.imageUrl, width: 112, height: 112, fit: BoxFit.cover, memCacheWidth: 112, memCacheHeight: 112),
              ),
              // "自营" 标签
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0e55b4), // 蓝色背景
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '自营',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 商品名称
          Text(product.name, style: AppTextStyles.bodySmall.copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          // 价格
          Text(Money.fromCents(product.priceCents).format(), style: AppTextStyles.priceSmall.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
