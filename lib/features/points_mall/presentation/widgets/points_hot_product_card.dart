import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';
import '../../data/models/points_mall_home_data.dart';

class PointsHotProductCard extends StatelessWidget {
  final PointsProduct product;
  final VoidCallback? onTap;

  const PointsHotProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    // 缩放因子调整为 1.6 倍，保证完美的排版布局与清晰的视觉效果
    const double scale = 1.3;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75 * scale,
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 上面是图片：75dp * 75dp 正方形且有 5dp 缩放圆角
            ClipRRect(
              borderRadius: BorderRadius.circular(5 * scale),
              child: SizedBox(
                width: 75 * scale,
                height: 75 * scale,
                child: AppNetworkImage(url: product.imageUrl, width: 75 * scale, height: 75 * scale, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 5),
            // 下面是名称：67dp * 37dp
            SizedBox(
              width: 75 * scale,
              height: 40 * scale,
              child: Text(
                product.name + "测试测试aaa 234234",
                style: const TextStyle(fontSize: 8 * scale, color: Color(0xFF000000), fontWeight: FontWeight.w500, height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            //const SizedBox(height: 2),
            // 名称下面是个 row
            SizedBox(
              width: 75 * scale,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 左侧：34dp * 14dp 精准移除固定高度与特定 height 约束以支持理想的垂直居中对齐
                  SizedBox(
                    width: 36 * scale,
                    child: Text(
                      '${product.points}积分',
                      style: const TextStyle(fontSize: 7.5 * scale, color: Color(0xFFFF2105), fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 右侧：25dp * 13dp
                  Container(
                    width: 26 * scale,
                    height: 14 * scale,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFF2105), width: 1),
                      borderRadius: BorderRadius.circular(67),
                    ),
                    child: Text(
                      '兑换',
                      style: TextStyle(fontSize: 8 * scale, color: const Color(0xFFFF2105), fontWeight: FontWeight.w500, height: 1.1),
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
