import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
    final defaultPlaceholder = placeholder ??
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: SizedBox.shrink()),
        );
    final defaultError = errorWidget ??
        Icon(
          Icons.image_not_supported_outlined,
          size: width ?? height ?? 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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