import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/models/reservation_service_item.dart';

/// 服务预约列表单项卡片（真实 API 数据）
///
/// 布局与 [ServiceListItem] 一致：左图（100x100）+ 中间文字 + 右侧按钮，
/// 图片来自网络 URL，无网络图时显示占位。
class ReservationServiceListItem extends StatelessWidget {
  final ReservationServiceItem item;
  final VoidCallback onBookTap;

  const ReservationServiceListItem({super.key, required this.item, required this.onBookTap});

  @override
  Widget build(BuildContext context) {
    final subtitle = item.subtitle.isNotEmpty ? item.subtitle : '';
    return Row(
      children: [
        // 左侧图片：100x100，圆角 10，cover 裁剪
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: AppNetworkImage(
            url: item.headImgUrl,
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
        // 中间文字区域：垂直居中
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.serviceName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF000000), height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.4),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 22),
        // 右侧预约按钮：红色描边胶囊形
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 31,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 78),
              child: OutlinedButton(
                onPressed: onBookTap,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.serviceButtonRed),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '立即预约',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.serviceButtonRed),
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
