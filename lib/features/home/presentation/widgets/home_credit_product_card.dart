import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../points_mall/data/models/get_recommend_product_list_model.dart';

/// 首页热卖商品卡片（compact 模式，95px 宽）
/// 数据源：CreditMallProduct（推荐位接口）
class HomeCreditProductCard extends StatelessWidget {
  final CreditMallProduct product;

  const HomeCreditProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    const cardWidth = 95.0;
    const imageHeight = 95.0;

    return SizedBox(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片 95x95
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppNetworkImage(
              url: product.imgUrl,
              width: cardWidth,
              height: imageHeight,
              fit: BoxFit.cover,
              memCacheWidth: cardWidth.toInt(),
              memCacheHeight: imageHeight.toInt(),
            ),
          ),
          const SizedBox(height: 6),
          // 商品名称（"自营"标签在名称正前方，背景色为 #213775）
          Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF213775),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      '自营',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                TextSpan(text: product.productName, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // 价格 + 右侧购物车图标，对齐原 HomeProductCard 展示形式
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 第一行：积分价 creditPrice
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${product.creditPrice}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF2121),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          '积分',
                          style: TextStyle(fontSize: 10, color: Color(0xFFFF2121)),
                        ),
                      ],
                    ),
                    // 第二行：市场价 marketPrice（划线）
                    Text(
                      '¥${product.marketPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF8E8E93),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
              // 右侧：红色购物车图标 #FF2105
              const Icon(
                Icons.shopping_cart_outlined,
                size: 20,
                color: Color(0xFFFF2105),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
