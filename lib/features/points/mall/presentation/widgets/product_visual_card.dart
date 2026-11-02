import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

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

          // 商品详情富文本区域：接口 description 可能包含 HTML 标签
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: HtmlWidget(
                  product.description.trim().isEmpty ? '<p>暂无商品详情</p>' : product.description,
                  textStyle: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.6),
                  customStylesBuilder: (element) {
                    if (element.localName == 'img') {
                      return {'width': '100%', 'height': 'auto'};
                    }
                    return null;
                  },
                ),
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
