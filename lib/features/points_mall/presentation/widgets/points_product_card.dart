import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../data/models/points_mall_home_data.dart';

/// 积分商城商品卡片
class PointsProductCard extends StatelessWidget {
  final PointsProduct product;

  const PointsProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, // 恢复基础宽度，解决横向滚动列表崩溃问题
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1.2, // 调回 1.2，降低图片高度
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
              child: AppNetworkImage(url: product.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 32, // 固定标题区域高度，防止溢出
                  child: Text(
                    product.name,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, size: 12, color: Color(0xFFFF8F00)),
                    const SizedBox(width: 2),
                    Text(
                      '${product.points}',
                      style: AppTextStyles.priceSmall.copyWith(
                        color: const Color(0xFFFF8F00),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '剩${product.stock}件',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
