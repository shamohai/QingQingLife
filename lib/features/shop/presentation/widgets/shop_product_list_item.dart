import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/models/service_tier.dart';

class ShopProductListItem extends StatelessWidget {
  final ShopProductItem product;
  final VoidCallback? onAddToCart;

  const ShopProductListItem({super.key, required this.product, this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: AppNetworkImage(url: product.imageUrl!, fit: BoxFit.cover),
                  )
                : const Center(child: Icon(Icons.image_outlined, size: 32, color: AppColors.outline)),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (product.tag != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppRadius.xs)),
                    child: Text(product.tag!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Text(
                  product.name,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${product.price.toStringAsFixed(1)}元',
                  style: AppTextStyles.priceSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onAddToCart,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0x99FFFFFF), shape: BoxShape.circle),
              child: const Icon(Icons.shopping_cart, size: 22, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
