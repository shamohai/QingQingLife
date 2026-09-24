import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/service_card_data.dart';

/// 服务列表单项卡片
///
/// 布局：左图（100x100）+ 中间文字 + 右侧红色描边预约按钮
/// 点击整个卡片跳转到客服页面（一期 placeholder，后续对接服务详情路由）
/// 圆角由外层 Container(radius 10) 统一处理，本组件自身无圆角
class ServiceListItem extends StatelessWidget {
  final ServiceCardData data;
  final VoidCallback onTap;

  const ServiceListItem({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Row(
            children: [
              // 左侧图片：100x100，圆角 10，cover 裁剪
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
              const SizedBox(width: AppSpacing.sm),
              // 中间文字区域：垂直居中
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF000000), height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      data.subtitle,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.4),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // 右侧预约按钮：红色描边胶囊形，最小 78x31，垂直居中
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
      ),
    );
  }
}
