import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';

/// 积分商城 Banner（单张大图）
class PointsBanner extends StatelessWidget {
  final String imageUrl;
  final double height;

  const PointsBanner({
    super.key,
    required this.imageUrl,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AppNetworkImage(
          url: imageUrl,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
