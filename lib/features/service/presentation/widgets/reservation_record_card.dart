import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/reservation_record_item.dart';

/// 预约/报名记录列表中的单项卡片（真实 API 数据）。
///
/// 全宽白色卡片，固定 99dp 高，圆角 10dp。内部结构：
///  1. 标题行：左侧服务名称 + 蓝色分类胶囊标签（左对齐），右侧"查看详情"文字+箭头
///  2. 预约编号行（reservationid）
///  3. 预约时间行（reservationdatetime）
///  4. 状态行（statusname，仅待审核/已通过/已拒绝时展示）
///
/// 点击"查看详情"跳转到预约服务详情页（/service/project/:serviceid）。
class ReservationRecordCard extends StatelessWidget {
  final ReservationRecordItem item;
  final VoidCallback? onViewTap;

  const ReservationRecordCard({super.key, required this.item, this.onViewTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 99),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行：左侧标题 + 分类标签，右侧查看详情
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 服务名称
                      Flexible(
                        child: Text(
                          item.serviceName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface, height: 1.33),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.serviceTypeName.isNotEmpty) ...[
                        const SizedBox(width: 5),
                        // 分类标签：蓝色小胶囊
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.serviceTabActive, borderRadius: BorderRadius.circular(AppRadius.xs)),
                          child: Text(
                            item.serviceTypeName,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white, height: 1.0),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // 查看详情 + 箭头
                GestureDetector(
                  onTap: onViewTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '查看详情',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.5),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFF8E8E93)),
                    ],
                  ),
                ),
              ],
            ),
            // 预约编号（8px 间距）
            const SizedBox(height: 8),
            Text(
              '预约编号：${item.reservationId}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.5),
            ),
            // 预约时间（6px 间距）
            const SizedBox(height: 6),
            Text(
              '预约时间：${item.reservationDateTime}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.5),
            ),
            // 状态行（仅非空时展示）
            if (item.statusName.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusDot(item.statusName),
                  const SizedBox(width: 4),
                  Text(
                    item.statusName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.5),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 状态指示点：待审核=橙色，已通过/已完成=绿色，已拒绝=红色
  Widget _buildStatusDot(String statusName) {
    Color color;
    if (statusName.contains('已拒绝') || statusName.contains('拒绝')) {
      color = const Color(0xFFFF5252);
    } else if (statusName.contains('已通过') || statusName.contains('已完成') || statusName.contains('通过')) {
      color = const Color(0xFF34C759);
    } else {
      color = const Color(0xFFFF9500);
    }
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
