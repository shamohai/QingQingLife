import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/widgets/app_image.dart';

/// 金刚区：10格图标导航（2行5列），白色卡片容器
/// 设计稿：66x66 图标 + 14px 黑色文字，16px 水平间距
class HomeKingKongGrid extends StatelessWidget {
  final List<HomeKingKongItem> items;

  const HomeKingKongGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      // 去掉 height，依靠内边距和网格内容自然撑高
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(AppRadius.md))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/home/kingkong_member.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                  child: const Icon(Icons.local_fire_department, size: 10, color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('积分兑换', style: AppTextStyles.headlineSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            childAspectRatio: 0.78, // 进一步微调 aspect ratio 以确保在不同设备下文字不会发生 3.3 像素的垂直溢出
            crossAxisSpacing: 12,
            mainAxisSpacing: 8, // 减少垂直间距，给图标和文字留出更多安全高度
            children: List.generate(items.length > 10 ? 10 : items.length, (i) => _KingKongItem(item: items[i])),
          ),
        ],
      ),
    );
  }
}

class _KingKongItem extends StatelessWidget {
  final HomeKingKongItem item;
  const _KingKongItem({required this.item});

  void _handleTap(BuildContext context) {
    final link = item.actionUrl;
    if (link != null) context.push(link);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 44, // 44x44 图标尺寸，为 5 列网格和文字保留充足空间
            height: 44,
            child: item.iconUrl.isNotEmpty
                ? AppNetworkImage(url: item.iconUrl, fit: BoxFit.contain, memCacheWidth: 88, memCacheHeight: 88)
                : Container(
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: const Center(child: Icon(Icons.category_outlined, size: 24, color: Colors.grey)),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12, // 设计稿 12px 标准标签字号
              color: const Color(0xFF1A1D1C), // 设计稿黑色文字
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
