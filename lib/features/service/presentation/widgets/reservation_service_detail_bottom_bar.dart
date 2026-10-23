import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../domain/models/reservation_service_detail_model.dart';

/// 预约服务详情 — 底部固定操作栏（服务预约 tab 真实 API 数据）
///
/// 固定高度 80dp，白色背景，顶部阴影。
/// 居中放置深蓝色渐变胶囊按钮，点击跳转到填写信息页（携带 serviceId、serviceName、headImgUrl）。
class ReservationServiceDetailBottomBar extends StatelessWidget {
  final ReservationServiceDetail detail;

  const ReservationServiceDetailBottomBar({super.key, required this.detail});

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
              context.pushNamed(
                'serviceBookingForm',
                pathParameters: {'id': detail.serviceId.toString()},
                queryParameters: {'title': detail.serviceName, 'heroAsset': detail.headImgUrl},
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
                  '立即预约',
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
