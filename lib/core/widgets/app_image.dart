import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// 统一网络图片组件，封装 CachedNetworkImage 并统一错误/占位处理
///
/// 业务页面禁止直接调用 Image.network，统一使用此组件。
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final double? rawWidth = width;
    final double? rawHeight = height;

    // Use a finite size for the fallback icon.
    // If width or height is provided and finite, use it (clamped to a reasonable max for icons).
    // Otherwise default to 48.0.
    double iconSize = 48.0;
    if (rawWidth != null && rawWidth.isFinite) {
      iconSize = math.min(rawWidth, 48.0);
    } else if (rawHeight != null && rawHeight.isFinite) {
      iconSize = math.min(rawHeight, 48.0);
    }

    final defaultPlaceholder = placeholder ??
        Container(
          color: AppColors.surfaceVariant,
          child: const Center(child: SizedBox.shrink()),
        );
    final defaultError = errorWidget ??
        Icon(
          Icons.image_not_supported_outlined,
          size: iconSize,
          color: AppColors.onSurfaceVariant,
        );

    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => defaultPlaceholder,
      errorWidget: (_, __, ___) => defaultError,
    );

    if (radius > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: image,
      );
    }

    return image;
  }
}