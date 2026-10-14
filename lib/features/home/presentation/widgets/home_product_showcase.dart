import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_image.dart';

/// 底部商品展示区
/// 设计稿：3个商品卡片，显示会员价，横向排列
class HomeProductShowcase extends StatelessWidget {
  final List<ProductCard> products;

  const HomeProductShowcase({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(14))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('为您推荐', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: products.isEmpty
                ? const Center(child: Text('暂无商品', style: AppTextStyles.bodySmall))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length > 3 ? 3 : products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: EdgeInsets.only(right: index < (products.length > 3 ? 3 : products.length) - 1 ? AppSpacing.md : 0),
                        child: _ShowcaseProductCard(product: product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ShowcaseProductCard extends StatelessWidget {
  final ProductCard product;

  const _ShowcaseProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AppNetworkImage(url: product.imageUrl, width: 130, height: 130, fit: BoxFit.cover, memCacheWidth: 130, memCacheHeight: 130),
          ),
          const SizedBox(height: 8),
          // 商品名称
          Text(product.name, style: AppTextStyles.bodySmall.copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          // 会员价
          Row(
            children: [
              const Text('会员价 ', style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
              Text(Money.fromCents(product.priceCents).format(), style: AppTextStyles.priceMedium.copyWith(fontSize: 14)),
            ],
          ),
          if (product.originalPriceCents != null && product.originalPriceCents! > product.priceCents) ...[
            const SizedBox(height: 2),
            Text(
              Money.fromCents(product.originalPriceCents!).format(),
              style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF999999), decoration: TextDecoration.lineThrough, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}
