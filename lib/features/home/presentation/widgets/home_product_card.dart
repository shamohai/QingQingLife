import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_image.dart';

class HomeProductCard extends StatelessWidget {
  final ProductCard product;
  final bool compact;

  const HomeProductCard({super.key, required this.product, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final cardWidth = compact ? 112.0 : 160.0;
    final imageHeight = compact ? 112.0 : 120.0;
    return SizedBox(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // 商品图片
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: AppNetworkImage(
                  url: product.imageUrl,
                  width: cardWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                  memCacheWidth: cardWidth.toInt(),
                  memCacheHeight: imageHeight.toInt(),
                ),
              ),
              if (product.tag != null)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.xs)),
                    child: Text(product.tag!, style: AppTextStyles.tagStyle),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // 商品名称
          Text(product.name, style: AppTextStyles.bodySmall, maxLines: compact ? 1 : 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.xs),
          // 价格
          Text(Money.fromCents(product.priceCents).format(), style: AppTextStyles.priceMedium),
          if (product.salesCount != null) ...[
            const SizedBox(height: 2),
            Text('${product.salesCount}人付款', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
