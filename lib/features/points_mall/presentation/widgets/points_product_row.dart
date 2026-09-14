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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AppNetworkImage(
            url: product.imageUrl,
            width: 112,
            height: 112,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurface,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${product.points}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      shape: const StadiumBorder(),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '兑换',
                      style: TextStyle(fontSize: 12, color: Color(0xFFFF2105)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
