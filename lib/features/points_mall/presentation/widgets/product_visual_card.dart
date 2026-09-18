import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_image.dart';
import '../../data/models/service_product_detail_model.dart';

/// 积分商城服务商品详情 — 商品图片 + 详情区域卡片
///
/// 白色卡片（height=721px），内含：
/// - 蓝色渐变进度条（绝对定位 top=29）
/// - 主商品大图（绝对定位 top=53, width=350, height=659）
/// - "商品详情"标签（绝对叠加在图片左上 top=12）
/// - 描述文本卡片（绝对叠加在图片下半区 top=611, height=120）
class ProductVisualCard extends StatelessWidget {
  final ServiceProductDetail product;

  const ProductVisualCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // 设计稿 block_4: width=414, height=814, margin-left=13, margin-top=91
    // 归一化: width=367(≈350+左右padding), height=721
    const double cardHeight = 721;
    // 描述卡：设计稿 top=640 relative to block_4 → 640*0.886≈567
    // 但为使卡片视觉饱满，调整为顶 611（使卡底部到 731，略超出卡片边界）
    const double descCardTop = 611;
    const double descCardHeight = 120; // 4行文字 ≈ 15+4*21+15=114，取120

    return Container(
      height: cardHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 蓝色渐变进度条装饰（设计稿：94×7，left=10, top=29）
          Positioned(
            left: 10,
            top: 29,
            child: Container(
              width: 83,
              height: 6,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(999)),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF0088FF), Color(0x000088FF)],
                ),
              ),
            ),
          ),

          // 主商品大图（设计稿：395×744，left=10, top=53）
          Positioned(
            left: 10,
            top: 53,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              child: AppNetworkImage(
                url: product.mainImageUrl,
                width: 350,
                height: 659,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // "商品详情"标签（叠加在图片左上，设计稿：position:absolute; left=10, top=12）
          Positioned(
            left: 10,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: const Text(
                '商品详情',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2024)),
              ),
            ),
          ),

          // 描述文本卡片（设计稿：left=14, top=640, width=414, height=115）
          // 归一化：left≈13, top≈567→611（调整使卡片视觉饱满）, width≈347, height≈120
          Positioned(
            left: 13,
            top: descCardTop,
            child: SizedBox(
              width: 347,
              height: descCardHeight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: const Text(
                  '持本旅游券即可兑换青海环线 3 天 2 晚跟团之旅，打卡青海经典核心美景，远离城市喧嚣，沉浸式感受青藏高原辽阔风光。行程轻松不赶路，适合朋友结伴、家庭出游，随团省心出行，不用费心规划路线。',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF1F2024), height: 1.5),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
