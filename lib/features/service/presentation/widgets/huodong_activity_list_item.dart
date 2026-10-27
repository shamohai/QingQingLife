import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/models/offline_activity_item.dart';

/// 活动报名列表单项卡片（真实 API 数据）
///
/// 样式与原 [ServiceActivityCardItem] 一致：左图（100x100 网络图）
/// + 标题（18px w500，1行）+ 日期行（access_time icon + 日期 14px）
/// + 限制条件行（account_circle icon + 限制条件 14px）
/// + 状态行（进行中/已结束，不同颜色）
/// + 固定 78x31 红色描边"立即报名"按钮
/// 图片来自网络 URL，无图时显示占位。
class HuodongActivityListItem extends StatelessWidget {
  final OfflineActivityItem item;
  final VoidCallback onTap;

  const HuodongActivityListItem({super.key, required this.item, required this.onTap});

  /// 根据开始时间和结束时间判断活动状态
  /// 返回 true 表示进行中，false 表示已结束
  bool _isActivityOngoing() {
    if (item.startDate.isEmpty || item.endDate.isEmpty) return false;
    try {
      final now = DateTime.now();
      final start = DateTime.parse(item.startDate);
      final end = DateTime.parse(item.endDate);
      // 结束日期包含当天，所以比较时要把结束日期设为当天 23:59:59
      final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
      return now.isAfter(start.subtract(const Duration(days: 1))) && now.isBefore(endOfDay.add(const Duration(days: 1)));
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOngoing = _isActivityOngoing();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左侧图片：100x100，圆角 sm，cover 裁剪，网络图
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: AppNetworkImage(
            url: item.postUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            radius: AppRadius.sm,
            placeholder: Container(
              width: 100,
              height: 100,
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.image_outlined, size: 36, color: AppColors.outline),
            ),
            errorWidget: Container(
              width: 100,
              height: 100,
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.image_outlined, size: 36, color: AppColors.outline),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // 中间文字区域：标题（18px w500，1行）+ 日期行（access_time icon）
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF000000), height: 1.33),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (item.dateRangeDisplay.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.black),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.dateRangeDisplay,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.43),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (item.dateRangeDisplay.isNotEmpty) const SizedBox(height: 8),
              if (item.limitations.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 18, color: Colors.black),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.limitations,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.43),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (item.limitations.isNotEmpty) const SizedBox(height: 3),
              // 状态行：进行中/已结束 + 右侧报名按钮
              Row(
                children: [
                  const Icon(Icons.flag_outlined, size: 18, color: Colors.black),
                  const SizedBox(width: 10),
                  Text(
                    isOngoing ? '进行中' : '已结束',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isOngoing ? AppColors.serviceButtonRed : AppColors.outline,
                      height: 1.43,
                    ),
                  ),
                  const Spacer(),
                  // 报名按钮：固定 78x31，红色描边
                  SizedBox(
                    height: 31,
                    width: 78,
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.serviceButtonRed),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '立即报名',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.serviceButtonRed,
                        ),
                        softWrap: false,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
