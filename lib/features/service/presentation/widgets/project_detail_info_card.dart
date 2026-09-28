import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/service_project_detail_model.dart';

/// 预约项目详情 — 白色圆角信息卡片（四角圆角）
///
/// 结构（使用 Stack 精确控制内部元素位置）：
///  - 标题 "项目简介"：24sp/Semibold，left=19，top=10
///  - 蓝色渐变分割线：94x7，borderRadius=999，left=19，top=35
///  - 描述正文：16sp/Regular，lineHeight=1.5，padding left=10 top=18 right=10 bottom=107
///
/// 卡片四角圆角（AppRadius.md），带轻微阴影。
class ProjectDetailInfoCard extends StatelessWidget {
  final ServiceProjectDetail product;

  const ProjectDetailInfoCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 558,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Stack(
          children: [
            // 白色卡片背景：四角圆角，带轻微阴影
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                  boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
                ),
              ),
            ),
            // 标题 "项目简介"
            Positioned(
              left: 19,
              top: 10,
              child: const Text('项目简介', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
            ),
            // 蓝色渐变分割线
            Positioned(
              left: 19,
              top: -200,
              child: Container(
                width: 94,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.round),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [AppColors.serviceProjectBlue, Color(0x00F3F5F7)],
                  ),
                ),
              ),
            ),
            // 描述正文
            Positioned(
              left: 10,
              top: 18,
              right: 10,
              bottom: 107,
              child: Text(
                product.description,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}