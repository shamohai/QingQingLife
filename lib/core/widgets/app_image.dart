import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// 统一网络图片展示组件
/// 
/// 基于 [cached_network_image] 封装，实现了以下功能：
/// 1. 自动进行内存与磁盘二级缓存，减少流量消耗。
/// 2. 统一了图片加载中的占位图风格（Placeholder）。
/// 3. 统一了加载失败后的错误视图（ErrorWidget）。
/// 4. 支持便捷的圆角裁剪。
/// 
/// [重要] 业务开发中应杜绝直接使用 Image.network，以确保用户体验的一致性。
class AppNetworkImage extends StatelessWidget {
  final String url;          // 图片远程 URL
  final double? width;       // 指定宽度
  final double? height;      // 指定高度
  final BoxFit fit;          // 填充模式
  final double radius;       // 圆角大小
  final Widget? placeholder; // 可选：自定义加载占位图
  final Widget? errorWidget; // 可选：自定义错误显示

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

    // 自动计算默认错误图标的大小，防止在极小或极大容器中比例失调
    double iconSize = 48.0;
    if (rawWidth != null && rawWidth.isFinite) {
      iconSize = math.min(rawWidth, 48.0);
    } else if (rawHeight != null && rawHeight.isFinite) {
      iconSize = math.min(rawHeight, 48.0);
    }

    // 统一的占位背景
    final defaultPlaceholder = placeholder ??
        Container(
          color: AppColors.surfaceVariant,
          child: const Center(child: SizedBox.shrink()),
        );
        
    // 统一的加载失败视图
    final defaultError = errorWidget ??
        Icon(
          Icons.image_not_supported_outlined,
          size: iconSize,
          color: AppColors.onSurfaceVariant,
        );

    // 判断是否为本地资源路径
    final bool isAsset = url.startsWith('assets/');

    Widget image;
    if (isAsset) {
      image = Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => defaultError,
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => defaultPlaceholder,
        errorWidget: (_, __, ___) => defaultError,
      );
    }

    // 如果设置了圆角，则使用 ClipRRect 进行裁剪
    if (radius > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: image,
      );
    }

    return image;
  }
}
