import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/service_card_data.dart';

/// 活动报名专用卡片组件
///
/// 布局：左图（100x100）+ 右侧文字区（标题 + 日期行 + 人数行）+ 右下报名按钮
/// 点击报名按钮跳转到服务项目详情页
class ServiceActivityCardItem extends StatelessWidget {
  final ServiceCardData data;
  final VoidCallback onTap;

  const ServiceActivityCardItem({
    super.key,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧图片：100x100，圆角 sm，cover 裁剪
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Image.asset(
              data.imageAsset,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.image_outlined, size: 36, color: AppColors.outline),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // 右侧：标题 + 日期行 + 人数行（垂直堆叠）
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 标题：18dp Medium #000
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF000000),
                    height: 1.33,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                // 日期行：日历图标 + 日期文字
                if (data.dateRange != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Color(0xFF8E8E93)),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        data.dateRange!,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.43),
                        maxLines: 1,
                      ),
                    ],
                  ),
                if (data.dateRange != null) const SizedBox(height: AppSpacing.xs),
                // 人数行：人群图标 + 人数文字
                if (data.limitCount != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people, size: 18, color: Color(0xFF8E8E93)),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '限${data.limitCount}人',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.43),
                        maxLines: 1,
                      ),
                    ],
                  ),
                const SizedBox(width: AppSpacing.md),
                // 右侧报名按钮：红色描边胶囊形，高 31，宽 78，垂直居中
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 31,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 78),
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.serviceButtonRed),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          data.buttonText,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.serviceButtonRed),
                          softWrap: false,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
