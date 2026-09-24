import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/service_card_data.dart';

/// 服务列表单项卡片
///
/// 布局：左图（100x100）+ 中间文字 + 右侧红色描边预约按钮
/// 点击整个卡片跳转到客服页面（一期 placeholder，后续对接服务详情路由）
/// 圆角规则：首项保留顶部圆角，尾项保留底部圆角，单项保留全部圆角，中间项无圆角
class ServiceListItem extends StatelessWidget {
  final ServiceCardData data;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const ServiceListItem({
    super.key,
    required this.data,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    // 计算圆角：首项顶部圆角，尾项底部圆角，单项全圆角，中间项无圆角
    final borderRadius = _calculateBorderRadius();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: const Color(0x08000000),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Row(
            children: [
              // 左侧图片：100x100，圆角 10，cover 裁剪
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
              // 中间文字区域：垂直居中
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8E8E93),
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // 右侧预约按钮：红色描边胶囊形，高 36，垂直居中
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.serviceButtonRed),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    ),
                    child: Text(
                      data.buttonText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.serviceButtonRed,
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

  BorderRadius _calculateBorderRadius() {
    final radius = AppRadius.lg;
    if (isFirst && isLast) {
      // 只有一张卡片：四个角都有圆角
      return BorderRadius.all(Radius.circular(radius));
    } else if (isFirst) {
      // 第一张卡片：左上角、右上角有圆角
      return BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      );
    } else if (isLast) {
      // 最后一张卡片：左下角、右下角有圆角
      return BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
    } else {
      // 中间卡片：无圆角
      return BorderRadius.zero;
    }
  }
}
