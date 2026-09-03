import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import 'home_product_card.dart';
import 'home_new_user_gift_card.dart';

/// 新人礼 + 可用商品组合模块（同一白色卡片容器）
class HomePromoSection extends StatelessWidget {
  final List<HomeNewUserGift> gifts;
  final List<ProductCard> products;
  final VoidCallback? onManageServiceTap;

  const HomePromoSection({
    super.key,
    required this.gifts,
    required this.products,
    this.onManageServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeNewUserGiftCard(gifts: gifts),
            const SizedBox(height: AppSpacing.md),
            _buildProducts(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProducts(BuildContext context) {
    return Stack(
      children: [
        Column(
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
        if (onManageServiceTap != null)
          Positioned(
            right: 0,
            bottom: 0,
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
    );
  }
}
