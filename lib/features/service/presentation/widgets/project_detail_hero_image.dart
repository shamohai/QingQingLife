import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';

/// 预约项目详情 — Hero 主图区域
///
/// 尺寸固定 height=242（marginTop 13 + 图片 180 + 底部 padding 49），
/// 图片宽全屏减去左右各 14dp，高 180dp，cover 填充。
class ProjectDetailHeroImage extends StatelessWidget {
  final String heroAsset;

  const ProjectDetailHeroImage({super.key, required this.heroAsset});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)), // 这里设置圆角半径
          child: Image.asset(
            heroAsset,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}