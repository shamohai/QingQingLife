import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../../data/models/points_mall_home_data.dart';

class PointsProductCard extends StatelessWidget {
  final PointsProduct product;
  final VoidCallback? onExchange;
  final bool compact;

  const PointsProductCard({super.key, required this.product, this.onExchange, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sm)),
            child: AppNetworkImage(url: product.imageUrl, height: compact ? 74 : 112, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: compact ? AppSpacing.xs : AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontSize: compact ? 11 : 12, color: AppColors.onSurface, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: compact ? 2 : 4),
                Row(
                  children: [
                    Icon(Icons.stars, size: compact ? 10 : 12, color: const Color(0xFFFF2121)),
                    const SizedBox(width: 2),
                    Text('${product.points}', style: TextStyle(fontSize: compact ? 12 : 13, fontWeight: FontWeight.w600, color: const Color(0xFFFF2121))),
                    const SizedBox(width: 2),
                    Text('积分', style: TextStyle(fontSize: compact ? 9 : 10, color: const Color(0xFFFF2121))),
                  ],
                ),
              ],
            ),
          ),
          if (!compact)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.sm),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onExchange,
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFF2121), width: 0.8), padding: const EdgeInsets.symmetric(vertical: 4), shape: const StadiumBorder(), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('兑换', style: TextStyle(fontSize: 12, color: Color(0xFFFF2121))),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
