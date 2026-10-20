import 'package:flutter/material.dart';

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
    final cardWidth = compact ? 95.0 : 160.0;
    final imageHeight = compact ? 95.0 : 120.0;

    return SizedBox(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片 112x112
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppNetworkImage(
              url: product.imageUrl,
              width: cardWidth,
              height: imageHeight,
              fit: BoxFit.cover,
              memCacheWidth: cardWidth.toInt(),
              memCacheHeight: imageHeight.toInt(),
            ),
          ),
          const SizedBox(height: 6),
          // 商品名称（“自营”标签在名称正前方，背景色为 #213775）
          SizedBox(
            height: 52, // 固定 3 行文字高度，确保 2 行或 3 行商品的底部价格在同一水平线上
            child: Text.rich(
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
                      child: Text(
                        product.tag ?? '自营',
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                  TextSpan(text: product.name, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // 售价、市场价 + 右侧居中红色购物车图标 (#ffff2105)
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
                    Text(Money.fromCents(product.priceCents).format(), style: AppTextStyles.priceSmall.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(
                      product.originalPriceCents != null ? Money.fromCents(product.originalPriceCents!).format() : '¥940',
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
                size: 20,
                color: Color(0xFFFF2105), // #ffff2105 红色图标
              ),
            ],
          ),
        ],
      ),
    );
  }
}
