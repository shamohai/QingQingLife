import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import 'home_product_card.dart';

/// 可用商品横向展示
/// 设计稿：95x95 图片，"自营" 蓝色标签，名称，价格
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
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 24,
                    height: 24,
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
        // 商品列表 (支持横向滑动，每项 95px)
        SizedBox(
          height: 190,
          child: products.isEmpty
              ? const Center(child: Text('暂无可用商品', style: AppTextStyles.bodySmall))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    return HomeProductCard(product: products[index], compact: true);
                  },
                ),
        ),
      ],
    );
  }
}
