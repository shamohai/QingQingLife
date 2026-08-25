import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_image.dart';
import '../providers/shop_provider.dart';

class ShopProductCard extends StatelessWidget {
  final ShopProduct product;

  const ShopProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 210,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  AppNetworkImage(url: product.imageUrl, width: 160, height: 120, fit: BoxFit.cover),
                  if (product.tag != null)
                    Positioned(top: 6, left: 6, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.xs)),
                      child: Text(product.tag!, style: AppTextStyles.tagStyle),
                    )),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(product.name, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Flexible(
                            child: Text(Money.fromCents(product.priceCents).format(), style: AppTextStyles.priceMedium),
                          ),
                          if (product.originalPriceCents != null) ...[
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                Money.fromCents(product.originalPriceCents!).format(),
                                style: AppTextStyles.bodySmall.copyWith(decoration: TextDecoration.lineThrough, color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (product.salesCount != null) ...[
                        const SizedBox(height: 2),
                        Text('\${product.salesCount}人付款', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}