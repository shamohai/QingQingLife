import 'package:flutter/material.dart';

import 'cart_design_tokens.dart';
import 'cart_embedded_assets.dart';

enum CartProductImageVariant { thumbnail, recommendation }

class CartProductImage extends StatelessWidget {
  const CartProductImage({super.key, required this.variant, this.width, this.height, this.fit = BoxFit.contain, this.radius = 0});

  final CartProductImageVariant variant;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bytes = switch (variant) {
      CartProductImageVariant.thumbnail => cartThumbnailImageBytes,
      CartProductImageVariant.recommendation => cartRecommendationImageBytes,
    };

    Widget image = Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF3F7FB),
        child: const Icon(Icons.local_bar_outlined, color: CartDesignTokens.primary, size: 42),
      ),
    );

    if (radius > 0) {
      image = ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
    }

    return image;
  }
}
