import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../domain/models/service_project_detail_model.dart';

/// 预约项目详情 — 顶部导航栏
///
/// 左：返回图标（24x24 PNG）
/// 中：标题 "预约项目详情"
/// 右：文字链接 "预约说明"，颜色 #0088FF
class ProjectDetailHeader extends StatelessWidget {
  final ServiceProjectDetail product;

  const ProjectDetailHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Image.asset('assets/images/service/icon_back_project_detail.png', width: 24, height: 24),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text('预约项目详情', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
              ),
              GestureDetector(
                onTap: () => context.push(RouteNames.customerService),
                child: const Text('预约说明', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.serviceProjectBlue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}