import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_image.dart';
import '../../data/models/points_product_model.dart';

class PointsHotProductCard extends StatelessWidget {
  final PointsProduct product;
  final VoidCallback? onTap;

  const PointsHotProductCard({super.key, required this.product, this.onTap});

  /// 名称区域高度：3 行 × 12sp × 1.5，随系统字体缩放，避免大字体下被裁切
  static double _nameAreaHeight(TextScaler scaler) => scaler.scale(12) * 1.5 * 3;

  /// 卡片总高度（图片 100 + 间距 5 + 名称区 + 价格行），供外层横向列表使用
  static double totalHeight(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final priceHeight = scaler.scale(13) * 1.5; // 价格行实测约 19px，取 1.5 倍行高保证不小于实际高度
    return 100 + 5 + _nameAreaHeight(scaler) + priceHeight;
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 上面是图片：75dp * 75dp 正方形且有 5dp 缩放圆角
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                width: 100,
                height: 100,
                child: AppNetworkImage(url: product.imageUrl, width: 100, height: 100, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 5),
            // 下面是名称：宽度 100，高度按 3 行设计
            SizedBox(
              width: 100,
              height: _nameAreaHeight(scaler),
              child: Text(
                product.name,
                style: const TextStyle(fontSize: 12, color: Color(0xFF000000), fontWeight: FontWeight.w500, height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 左侧：积分数值。积分最大可能为 5 位数（如 20000），宽度不足时自动等比缩小，避免出现省略号
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${product.points}积分',
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFF2105), fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
