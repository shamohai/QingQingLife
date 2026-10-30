import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../pages/service_activity_booking_form_page.dart';
import '../pages/service_friend_booking_form_page.dart';
import '../../domain/models/service_project_detail_model.dart';

/// 预约项目详情 — 底部固定操作栏
///
/// 固定高度 80dp，白色背景，顶部阴影。
/// 居中放置深蓝色渐变胶囊按钮，报名页只接收当前详情对象。
class ProjectDetailBottomBar extends StatelessWidget {
  final ServiceProjectDetail product;

  const ProjectDetailBottomBar({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final btnWidth = screenWidth - 60;

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Center(
          child: GestureDetector(
            onTap: () {
              if (product.type == ServiceProjectDetailType.friend) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceFriendBookingFormPage(detail: product)));
                return;
              }
              if (product.type == ServiceProjectDetailType.activity) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceActivityBookingFormPage(detail: product)));
                return;
              }
              context.pushNamed(
                'serviceBookingForm',
                pathParameters: {'id': product.id.toString()},
                queryParameters: {'title': product.title, 'heroAsset': product.heroAsset},
              );
            },
            child: Container(
              width: btnWidth,
              height: 51,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.round),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.serviceCtaGradStart, AppColors.serviceTabActive],
                ),
              ),
              child: const Center(
                child: Text(
                  '立即报名',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white, height: 1.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
