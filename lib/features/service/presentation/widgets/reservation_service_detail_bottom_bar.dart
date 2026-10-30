import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../domain/models/reservation_service_detail_model.dart';

/// 预约服务详情 — 底部固定操作栏（服务预约 tab 真实 API 数据）
///
/// 固定高度 80dp，白色背景，顶部阴影。
/// - myReservationInfo 为 null：显示「立即预约」渐变按钮，可点击跳转报名页
/// - myReservationInfo 不为 null：显示「已报名」灰色按钮，不可点击
class ReservationServiceDetailBottomBar extends StatelessWidget {
  final ReservationServiceDetail detail;

  const ReservationServiceDetailBottomBar({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final btnWidth = screenWidth - 60;
    final hasReserved = detail.myReservationInfo != null;

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
            onTap: hasReserved
                ? null
                : () {
                    context.pushNamed(
                      'serviceBookingForm',
                      pathParameters: {'id': detail.serviceId.toString()},
                      extra: detail, // 传递完整的 detail 对象
                    );
                  },
            child: Container(
              width: btnWidth,
              height: 51,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.round),
                gradient: hasReserved
                    ? null
                    : const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [AppColors.serviceCtaGradStart, AppColors.serviceTabActive],
                      ),
                color: hasReserved ? AppColors.serviceButtonDisabled : null,
              ),
              child: Center(
                child: Text(
                  hasReserved ? '已预约' : '立即预约',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: hasReserved ? AppColors.serviceButtonDisabledText : Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
