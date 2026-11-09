import 'package:flutter/material.dart';

import '../../../../../app/theme/app_radius.dart';
import '../../data/models/service_product_detail_model.dart';

/// 积分商城服务商品详情 — 积分价格卡片
///
/// 橙色渐变背景，包含标题、标签胶囊、积分价格、库存/销量信息、市场价胶囊。
/// 通过负 margin 与 HeroSection 形成视觉叠加。
class ProductInfoCard extends StatelessWidget {
  final ServiceProductDetail product;

  const ProductInfoCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFFFF3C0C), Color(0xFFFF9564)]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== 需要左右留白的区域 ==========
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 16, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品标题
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 标签行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: product.tags.map((tag) => _TagPill(label: tag)).toList(),
                  ),
                  const SizedBox(height: 12),

                  // 积分价格 + 市场价
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 32,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 36),
                              child: Text(
                                '${product.points}',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white, height: 1.0),
                              ),
                            ),
                            const Positioned(
                              right: 0,
                              bottom: 4,
                              child: Text(
                                '积分',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        height: 25,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.round)),
                        child: Center(
                          child: Text(
                            '市场价:¥${product.marketPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFFF2105)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 剩余数量 / 已售
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '剩余数量：${product.remainingStock}张',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                      ),
                      Text(
                        '已售：${_formatSales(product.salesCount)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // // ========== 描述卡片：左右贴边，盖在渐变背景上 ==========
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.only(
            //       topLeft: const Radius.circular(14),
            //       topRight: const Radius.circular(14),
            //       bottomLeft: Radius.circular(AppRadius.lg),
            //       bottomRight: Radius.circular(AppRadius.lg),
            //     ),
            //   ),
            //   child: Text(
            //     product.description,
            //     style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF1F2024), height: 1.5),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  static String _formatSales(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万件';
    }
    return '$count件';
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.only(right: 8),
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white, height: 1.1),
        ),
      ),
    );
  }
}
