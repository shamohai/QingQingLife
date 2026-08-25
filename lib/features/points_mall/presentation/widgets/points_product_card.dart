import 'package:flutter/material.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';

/// 积分商城商品卡片
class PointsProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final int points;
  final int stock;

  const PointsProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.points,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
            child: AppNetworkImage(url: imageUrl, width: 160, height: 120, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.stars, size: 12, color: Color(0xFFFF8F00)),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '\${points}积分',
                        style: AppTextStyles.priceSmall.copyWith(color: const Color(0xFFFF8F00)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('剩余\${stock}件', style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}