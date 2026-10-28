import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/reservation_service_detail_model.dart';

/// 预约服务详情 — 副标题 + 预约须知 信息卡片
///
/// 仅在 [ReservationServiceDetail.subtitle] 或 [ReservationServiceDetail.reservationRemark]
/// 非空时渲染，用于展示 getreservationservicedetail 接口返回的附加信息。
///
/// 布局：
///  - 副标题（若有）：14sp/Regular，灰色
///  - 预约须知（若有）：14sp/Regular，黑色
///
/// 卡片：白色圆角（AppRadius.md），带轻微阴影。
class ReservationServiceDetailSubtleInfoCard extends StatelessWidget {
  final ReservationServiceDetail detail;

  const ReservationServiceDetailSubtleInfoCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final subtitle = detail.subtitle;
    final remark = detail.reservationRemark;

    // 两者都为空时不渲染
    if (subtitle.isEmpty && remark.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subtitle.isNotEmpty) ...[
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.5),
              ),
              if (remark.isNotEmpty) const SizedBox(height: AppSpacing.sm),
            ],
            if (remark.isNotEmpty) ...[
              Text(
                '预约须知',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                remark,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF333333), height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
