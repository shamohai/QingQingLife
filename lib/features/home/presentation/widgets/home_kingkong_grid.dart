import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../../core/widgets/app_image.dart';

/// 金刚区：10格图标导航（2行5列），白色卡片容器
/// 设计稿：66x66 图标 + 14px 黑色文字，16px 水平间距
class HomeKingKongGrid extends StatelessWidget {
  final List<HomeKingKongItem> items;

  const HomeKingKongGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(14)), // 设计稿 14px 圆角
        ),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 5,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16, // 设计稿 16px 水平间距
          mainAxisSpacing: 16,
          children: List.generate(items.length > 10 ? 10 : items.length, (i) => _KingKongItem(item: items[i])),
        ),
      ),
    );
  }
}

class _KingKongItem extends StatelessWidget {
  final HomeKingKongItem item;
  const _KingKongItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 66, // 设计稿 66px
          height: 66, // 设计稿 66px
          child: item.iconUrl.isNotEmpty
              ? AppNetworkImage(url: item.iconUrl, fit: BoxFit.contain, memCacheWidth: 132, memCacheHeight: 132)
              : Container(
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: const Center(child: Icon(Icons.category_outlined, size: 32, color: Colors.grey)),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          item.label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 14, // 设计稿 14px
            color: const Color(0xFF1A1D1C), // 设计稿黑色文字
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
