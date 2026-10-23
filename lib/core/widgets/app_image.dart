import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../app/config/app_config.dart';
import '../../app/theme/app_colors.dart';

/// Converts image paths returned by older API endpoints into usable URLs.
///
/// The order API may return a fully qualified URL, a protocol-relative URL,
/// or a path relative to the API host. Keeping this conversion here avoids
/// each feature making a different assumption about image hosting.
String? normalizeImageUrl(String raw) {
  var value = raw.trim();
  if (value.isEmpty) return null;

  // 清理转义符、Lanhu 导出切图中的星号 (*) 及内部空格
  value = value.replaceAll('&amp;', '&').replaceAll('\\', '/').replaceAll('*', '').replaceAll(' ', '');
  if (value.length >= 2 && ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'")))) {
    value = value.substring(1, value.length - 1).trim();
  }
  if (value.isEmpty) return null;

  if (value.startsWith('assets/') || value.startsWith('data:') || value.startsWith('blob:')) {
    return value;
  }
  if (value.startsWith('//')) return 'https:$value';
  if (value.startsWith('www.')) return 'https://$value';

  final parsed = Uri.tryParse(value);
  if (parsed != null && parsed.hasScheme) return parsed.toString();

  final base = AppConfig.baseUrl.endsWith('/') ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1) : AppConfig.baseUrl;
  final resolved = value.startsWith('/') ? '$base$value' : '$base/$value';
  return Uri.parse(resolved).toString();
}

/// 统一网络图片展示组件
///
/// 基于 [cached_network_image] 封装，实现了以下功能：
/// 1. 自动进行内存与磁盘二级缓存，减少流量消耗。
/// 2. 统一了图片加载中的占位图风格（Placeholder）。
/// 3. 统一了加载失败后的错误视图（ErrorWidget）。
/// 4. 支持便捷的圆角裁剪。
///
/// Web 端使用 Flutter 原生网络图片，避免 cached_network_image 在 Web 重建
/// 场景下的缓存/错误状态问题；移动端继续使用 cached_network_image。
class AppNetworkImage extends StatelessWidget {
  final String url; // 图片远程 URL
  final double? width; // 指定宽度
  final double? height; // 指定高度
  final BoxFit fit; // 填充模式
  final double radius; // 圆角大小
  final Widget? placeholder; // 可选：自定义加载占位图
  final Widget? errorWidget; // 可选：自定义错误显示

  /// 缓存原始图片的宽高限制（用于优化内存，特别是 CanvasKit）
  /// 如果图片很大但显示区域很小，建议传入此参数。
  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = normalizeImageUrl(url);
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
    final defaultPlaceholder =
        placeholder ??
        Container(
          color: AppColors.surfaceVariant,
          child: const Center(child: SizedBox.shrink()),
        );

    // 统一的加载失败视图
    final defaultError = errorWidget ?? Icon(Icons.broken_image_outlined, size: iconSize, color: AppColors.onSurfaceVariant);

    if (normalizedUrl == null) return defaultError;

    // 判断是否为本地资源路径
    final bool isAsset = normalizedUrl.startsWith('assets/');

    Widget image;
    if (isAsset) {
      image = Image.asset(
        normalizedUrl,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        errorBuilder: (context, error, stackTrace) => defaultError,
      );
    } else if (kIsWeb) {
      // cached_network_image 在 Web 上的缓存支持有限，列表/Tab 重建后
      // 可能复用错误状态。原生 Image.network 交给浏览器处理图片缓存。
      image = Image.network(
        normalizedUrl,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return defaultPlaceholder;
        },
        errorBuilder: (context, error, stackTrace) => defaultError,
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: normalizedUrl,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        placeholder: (context, url) => defaultPlaceholder,
        errorWidget: (context, url, error) => defaultError,
      );
    }

    // 如果设置了圆角，则使用 ClipRRect 进行裁剪
    if (radius > 0) {
      image = ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
    }

    return image;
  }
}
