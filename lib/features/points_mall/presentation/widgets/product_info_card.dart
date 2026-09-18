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
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 16, right: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFF9564), Color(0xFFFF3C0C)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 商品标题
              Text(
                product.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // 标签行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: product.tags.map((tag) => _TagPill(label: tag)).toList(),
              ),
              const SizedBox(height: 4),

              // 积分价格
              Row(
                children: [
                  Text(
                    '${product.points}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  const Text(
                    ' 积分',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // 剩余数量 / 已售
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '剩余数量:${product.remainingStock}张',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                  ),
                  Text(
                    '已售:${_formatSales(product.salesCount)}万件',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),

          // 市场价胶囊（绝对定位：设计稿 left=116px, top=118px → 归一化后 left≈103px）
          Positioned(
            left: 103,
            top: 118,
            child: Container(
              width: 111,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: const Center(
                child: Text(
                  '市场价:760.00',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFFF2105)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatSales(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(0)}';
    return count.toString();
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
    );
  }
}
