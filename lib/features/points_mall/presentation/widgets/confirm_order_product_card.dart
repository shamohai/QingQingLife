import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_image.dart';
import '../../data/models/service_product_detail_model.dart';

/// 确认订单商品卡片
class ConfirmOrderProductCard extends StatelessWidget {
  final ServiceProductDetail product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ConfirmOrderProductCard({super.key, required this.product, required this.quantity, required this.onIncrement, required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - 28).clamp(0.0, 414.0);
    return Container(
      width: cardWidth,
      height: 172,
      margin: const EdgeInsets.only(left: 10, right: 10, top: 0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          // 上半部分
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左侧：图片 + 名称 + 标签
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AppNetworkImage(url: product.mainImageUrl, width: 70, height: 70, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 170,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2024)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(children: product.tags.map((tag) => _TagPill(label: tag)).toList()),
                        ],
                      ),
                    ),
                  ],
                ),
                // 右侧：积分 + 市场价
                SizedBox(
                  width: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${product.points}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFFF2105)),
                          ),
                          const Text(
                            '积分',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFF2105)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '市场价:¥${product.marketPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 分隔线
          //const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F0F0)),

          // 下半部分
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            child: Column(
              children: [
                // 第一行：数量控件靠右
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // 靠右
                  children: [
                    _QtyButton(label: '-', onTap: onDecrement),
                    const SizedBox(width: 4),
                    Container(
                      width: 28,
                      alignment: Alignment.center,
                      child: Text(
                        '$quantity',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _QtyButton(label: '+', onTap: onIncrement),
                  ],
                ),
                const SizedBox(height: 10), // 两行间距，可按设计调整
                // 第二行：留言备注 左，填写提示 右
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '留言备注',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF1F2024)),
                    ),
                    const Text(
                      '请填写备注信息  >',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QtyButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD9D9D9)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      height: 17,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF2105)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Color(0xFFFF2105)),
        ),
      ),
    );
  }
}
