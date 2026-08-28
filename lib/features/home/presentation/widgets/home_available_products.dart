import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import 'home_product_card.dart';

/// 可用商品横向展示（3列固定）+ 管家服务悬浮按钮
class HomeAvailableProducts extends StatelessWidget {
  final List<ProductCard> products;
  final VoidCallback? onManageServiceTap;

  const HomeAvailableProducts({super.key, required this.products, this.onManageServiceTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('可用商品', style: AppTextStyles.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 168,
                  child: products.isEmpty
                      ? const Center(child: Text('暂无可用商品', style: AppTextStyles.bodySmall))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length > 3 ? 3 : products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Padding(
                              padding: EdgeInsets.only(right: index < (products.length > 3 ? 3 : products.length) - 1 ? AppSpacing.md : 0),
                              child: HomeProductCard(product: product, compact: true),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          if (onManageServiceTap != null)
            Positioned(
              right: -4,
              bottom: -8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onManageServiceTap,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.scrim, blurRadius: 8, offset: Offset(0, 4))],
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.round),
                      boxShadow: [BoxShadow(color: AppColors.overlay, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: const Text('管家服务', style: TextStyle(fontSize: 10, color: AppColors.onSurface, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}