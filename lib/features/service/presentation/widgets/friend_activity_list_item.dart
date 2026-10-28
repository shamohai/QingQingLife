import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/models/offline_activity_item.dart';

/// 挚友会列表单项卡片（真实 API 数据）
///
/// 样式与原 [ServiceListItem] 一致：左图（100x100 网络图）+ 标题（16px w500，2行）
/// + 副标题（12px）+ 红色描边"立即报名"按钮（胶囊形，最小宽 78）
/// 图片来自网络 URL，无图时显示占位。
class FriendActivityListItem extends StatelessWidget {
  final OfflineActivityItem item;
  final VoidCallback onTap;

  const FriendActivityListItem({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        // 中间文字区域：标题（16px w500，maxLines 2）+ 副标题（12px）
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF000000), height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.subtitle.isNotEmpty ? item.subtitle : '',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.4),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 22),
        // 右侧报名按钮：红色描边胶囊形，最小宽 78，高 31
        Align(
          alignment: Alignment.center,
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
                  '立即报名',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.serviceButtonRed,
                  ),
                  softWrap: false,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
