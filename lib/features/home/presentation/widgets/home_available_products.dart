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
        // 商品列表 (支持横向滑动，每项 112px)
        SizedBox(
          height: 192,
          child: products.isEmpty
              ? const Center(child: Text('暂无可用商品', style: AppTextStyles.bodySmall))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    return _AvailableProductCard(product: products[index]);
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppNetworkImage(
              url: product.imageUrl,
              width: 112,
              height: 112,
              fit: BoxFit.cover,
              memCacheWidth: 112,
              memCacheHeight: 112,
            ),
          ),
          const SizedBox(height: 6),
          // 商品名称（“自营”标签在名称正前方，背景色与首页背景 #213775 一致）
          Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF213775), // 首页藏青背景色 #213775
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      '自营',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                TextSpan(
                  text: product.name,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // 售价、市场价 + 右侧居中红色购物车图标 (#ffff2105，不加背景)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 售价 + 市场价
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Money.fromCents(product.priceCents).format(),
                      style: AppTextStyles.priceSmall.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      product.originalPriceCents != null
                          ? Money.fromCents(product.originalPriceCents!).format()
                          : '¥940',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF8E8E93), // #ff8e8e93 市场价颜色
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
              // 右侧居中：红色购物车图标 (#ffff2105)，无背景
              const Icon(
                Icons.shopping_cart_outlined,
                size: 18,
                color: Color(0xFFFF2105), // #ffff2105 红色图标
              ),
            ],
          ),
        ],
      ),
    );
  }
}
