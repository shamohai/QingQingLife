import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_image.dart';
import '../../data/models/points_product_model.dart';

class PointsHotProductCard extends StatelessWidget {
  final PointsProduct product;
  final VoidCallback? onTap;

  const PointsHotProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
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
            // 下面是名称：67dp * 37dp
            SizedBox(
              width: 100,
              height: 55,
              child: Text(
                product.name,
                style: const TextStyle(fontSize: 12, color: Color(0xFF000000), fontWeight: FontWeight.w500, height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            //const SizedBox(height: 2),
            // 名称下面是个 row
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
                  const SizedBox(width: 4),
                  // 右侧：25dp * 13dp
                  Container(
                    width: 32,
                    height: 14,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFF2105), width: 1),
                      borderRadius: BorderRadius.circular(67),
                    ),
                    child: Text(
                      '兑换',
                      style: TextStyle(fontSize: 11, color: const Color(0xFFFF2105), fontWeight: FontWeight.w500, height: 1.1),
                      textAlign: TextAlign.center,
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
