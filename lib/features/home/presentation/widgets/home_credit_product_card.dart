import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../points/mall/data/models/get_recommend_product_list_model.dart';

/// 首页热卖商品卡片（compact 模式，95px 宽）
/// 数据源：CreditMallProduct（推荐位接口）
///
/// 高度不写死：由内容自然撑开，字体缩放（大字体）时不会被裁切或溢出。
/// 外层需提供宽松的纵向空间（如 IntrinsicHeight / 无固定高度的 Row）。
class HomeCreditProductCard extends StatelessWidget {
  final CreditMallProduct product;

  const HomeCreditProductCard({super.key, required this.product});

  static const _cardWidth = 95.0;
  static const _imageHeight = 95.0;

  @override
  Widget build(BuildContext context) {
    // memCache 单位是物理像素，需按设备像素比换算，否则高分屏上图片会被放大发糊
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return SizedBox(
      width: _cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 商品图片 95x95
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppNetworkImage(
              url: product.imgUrl,
              width: _cardWidth,
              height: _imageHeight,
              fit: BoxFit.cover,
              memCacheWidth: (_cardWidth * dpr).round(),
              memCacheHeight: (_imageHeight * dpr).round(),
            ),
          ),
          const SizedBox(height: 6),
          // 商品名称（"自营"标签在名称正前方，背景色为 #213775），最多 3 行
          Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: const Color(0xFF213775), borderRadius: BorderRadius.circular(3)),
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
          // 价格 + 右侧购物车图标
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 第一行：积分价 creditPrice（宽度不足时等比缩小，避免横向溢出）
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${product.creditPrice}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF2121)),
                          ),
                          const SizedBox(width: 2),
                          const Text('积分', style: TextStyle(fontSize: 10, color: Color(0xFFFF2121))),
                        ],
                      ),
                    ),
                    // 第二行：市场价 marketPrice（划线）
                    Text(
                      '¥${product.marketPrice.toStringAsFixed(2)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, color: Color(0xFF8E8E93), decoration: TextDecoration.lineThrough),
                    ),
                  ],
                ),
              ),
              // 右侧：红色购物车图标 #FF2105
              const Icon(Icons.shopping_cart_outlined, size: 20, color: Color(0xFFFF2105)),
            ],
          ),
        ],
      ),
    );
  }
}
