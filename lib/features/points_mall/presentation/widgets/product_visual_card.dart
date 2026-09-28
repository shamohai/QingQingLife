import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_image.dart';
import '../../data/models/service_product_detail_model.dart';

/// 积分商城服务商品详情 — 商品图片 + 详情区域卡片
/// - 主图（350×659，固定比例）
/// - 描述卡（白色卡片，叠加在图片下半区视觉位置）
class ProductVisualCard extends StatelessWidget {
  final ServiceProductDetail product;

  const ProductVisualCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(14))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部留白（为进度条预留空间）
          const SizedBox(height: 10),

          // 商品详情 + 蓝色渐变条（有重叠）
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: SizedBox(
              width: 100,
              child: Stack(
                children: [
                  // 商品详情文字
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(4))),
                    child: const Text(
                      '商品详情',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2024)),
                    ),
                  ),
                  // 蓝色渐变条（定位在文字高度约 3/4 的位置）
                  const Positioned(
                    left: 10,
                    top: 20, // ← 关键值！控制垂直位置（可微调）
                    child: SizedBox(
                      width: 70,
                      height: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                          gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF0088FF), Color(0x000088FF)]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 主图区域：包含图片 + 叠加的"商品详情"标签
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10), // 左右两边留出 10 的边距
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [AppNetworkImage(url: product.mainImageUrl, width: double.infinity, fit: BoxFit.fitWidth)],
              ),
            ),
          ),

          // 分隔条：白色背景，承接下方描述卡
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
