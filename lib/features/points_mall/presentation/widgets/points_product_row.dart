import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../data/models/points_mall_home_data.dart';

/// 积分商城商品行（横向：图片 + 名称 + 积分 + 兑换按钮）
class PointsProductRow extends StatelessWidget {
  final PointsProduct product;
  final VoidCallback? onExchange;

  const PointsProductRow({
    super.key,
    required this.product,
    this.onExchange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AppNetworkImage(
            url: product.imageUrl,
            width: 120, // 调整为 120，跟热门兑换商品的图片尺寸（75 * 1.6 = 120）完全一致
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 4), // 上下留出 4 像素的呼吸安全空间
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${product.points}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF2105),
                      ),
                    ),
                    const Text(
                      ' 积分',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF2105),
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: onExchange,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF2105), width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: const StadiumBorder(),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '兑换',
                        style: TextStyle(fontSize: 12, color: Color(0xFFFF2105), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
