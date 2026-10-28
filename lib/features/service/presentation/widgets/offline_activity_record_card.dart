import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/offline_activity_record_item.dart';

/// 活动报名记录单项卡片。
///
/// 与预约记录卡片（ReservationRecordCard）保持一致的全宽白色卡片样式：
///  1. 标题行：左侧活动名称 + 类型胶囊标签，右侧"查看详情"文字+箭头
///  2. 活动时间行（活动开始日期 / 结束日期）
///  3. 参加时间行（优先显示 joinTime，为空则显示 signInTime）
class OfflineActivityRecordCard extends StatelessWidget {
  final OfflineActivityRecordItem item;
  final VoidCallback? onViewTap;

  const OfflineActivityRecordCard({super.key, required this.item, this.onViewTap});

  @override
  Widget build(BuildContext context) {
    // 参加时间：优先取 joinTime，为空则取 signInTime
    final participationTime = item.joinTime.isNotEmpty ? item.joinTime : (item.signInTime ?? '');
    final hasParticipationTime = participationTime.isNotEmpty;

    return Container(
      constraints: const BoxConstraints(minHeight: 99),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行：左侧标题 + 类型标签，右侧查看详情
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 活动名称
                      Flexible(
                        child: Text(
                          item.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface, height: 1.33),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.activityTypeName.isNotEmpty) ...[
                        const SizedBox(width: 5),
                        // 类型标签：蓝色小胶囊
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.serviceTabActive, borderRadius: BorderRadius.circular(AppRadius.xs)),
                          child: Text(
                            item.activityTypeName,
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
            // 活动时间（8px 间距）
            const SizedBox(height: 8),
            Text(
              '活动时间：$_activityTimeDisplay',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.5),
            ),
            // 参加时间（6px 间距，优先 joinTime，为空则 signInTime）
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: hasParticipationTime ? const Color(0xFF34C759) : const Color(0xFFFF9500), shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  hasParticipationTime ? '参加时间：$participationTime' : '待签到',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 活动时间展示：同一日只显示一个日期，不同日显示 "起始 至 结束"
  String get _activityTimeDisplay {
    if (item.activityStartDate.isEmpty && item.activityEndDate.isEmpty) return '';
    if (item.activityStartDate == item.activityEndDate) return item.activityStartDate;
    return '${item.activityStartDate} 至 ${item.activityEndDate}';
  }
}
