import 'package:flutter/material.dart';

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
      height: 242,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 49),
        child: Image.asset(
          heroAsset,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}