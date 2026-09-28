import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/service_record_item.dart';

/// 预约/报名记录列表中的单项卡片。
///
/// 全宽白色卡片，固定 99dp 高，圆角 10dp。内部结构：
///  1. 标题行：左侧标题文字 + 蓝色分类胶囊标签（左对齐），右侧"查看详情"文字+箭头
///  2. 预约编号行
///  3. 预约时间行
///
/// 点击整个卡片无跳转（一期 placeholder，后续对接详情路由）。
class ServiceRecordCard extends StatelessWidget {
  final ServiceRecordItem item;

  const ServiceRecordCard({super.key, required this.item});

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题
                      Text(
                        item.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface, height: 1.33),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 5),
                      // 分类标签：蓝色小胶囊，左对齐（padding-left 4px）
                      Container(
                        //height: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.serviceTabActive, borderRadius: BorderRadius.circular(AppRadius.xs)),
                        child: Text(
                          item.category,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white, height: 1.0),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // 查看详情 + 箭头
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '查看详情',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.5),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 16, color: const Color(0xFF8E8E93)),
                  ],
                ),
              ],
            ),
            // 预约编号（8px 间距）
            const SizedBox(height: 8),
            Text(
              '预约编号：${item.appointmentId}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.5),
            ),
            // 预约时间（6px 间距）
            const SizedBox(height: 6),
            Text(
              '预约时间：${item.appointmentTime}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
