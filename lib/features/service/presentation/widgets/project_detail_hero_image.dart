import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';

/// 预约项目详情 — Hero 主图区域
///
/// 支持本地 asset 和网络 URL 两种来源：
/// - 以 http 开头的 [heroAsset] 视为网络图片，使用 AppNetworkImage
/// - 否则视为本地 asset，使用 Image.asset
///
/// 尺寸固定 height=242（marginTop 13 + 图片 180 + 底部 padding 49），
/// 图片宽全屏减去左右各 14dp，高 180dp，cover 填充。
class ProjectDetailHeroImage extends StatelessWidget {
  final String heroAsset;
  final double horizontalPadding;
  final double? aspectRatio;

  const ProjectDetailHeroImage({super.key, required this.heroAsset, this.horizontalPadding = AppSpacing.lg, this.aspectRatio});

  bool get _isNetworkUrl => heroAsset.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final double? effectiveAspectRatio = aspectRatio;
    Widget imageWidget;

    if (_isNetworkUrl) {
      imageWidget = AppNetworkImage(
        url: heroAsset,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.asset(heroAsset, width: double.infinity, fit: BoxFit.cover);
    }

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          child: effectiveAspectRatio == null
              ? imageWidget
              : AspectRatio(aspectRatio: effectiveAspectRatio, child: imageWidget),
        ),
      ),
    );
  }
}