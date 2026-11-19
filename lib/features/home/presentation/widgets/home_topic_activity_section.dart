import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/widgets/app_image.dart';

/// 线下活动模块：横向滑动，每行约 2.25 个活动，图片为 16:9 横图（精简底部空白，按钮大小不变）。
class HomeTopicActivitySection extends StatelessWidget {
  final List<HomeTopicActivityBlock> blocks;
  const HomeTopicActivitySection({super.key, required this.blocks});

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.compactPageMargin, vertical: 8),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(AppRadius.md))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
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
                  child: const Icon(Icons.storefront, size: 10, color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('线下活动', style: AppTextStyles.headlineSmall),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '(线下欢聚启新章，面对面享好礼)',
                  style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF999999), fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 整体左右滑动列表 (每行约 2.25 个活动，16:9 横图)
          _buildHorizontalList(context, blocks),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<HomeTopicActivityBlock> blocks) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 容器内可用宽度 (减去两边 padding 24)
        final availableWidth = constraints.maxWidth - 24;
        final spacing = AppSpacing.sm; // 8.0
        // 每行大约 2.25 个活动，宽度加大 6
        final cardWidth = ((availableWidth - spacing * 1.25) / 2.25) + 6;
        // 16:9 比例横图高度
        final imageHeight = cardWidth * 9 / 16;
        // 列表容器高度 = 图片高度 + 文字区(26) + 间距(6) + 按钮(20) + 上下padding(2+0) = imageHeight + 54
        final listHeight = imageHeight + 58;

        return SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: blocks.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < blocks.length - 1 ? spacing : 0),
                child: _TopicCard(block: blocks[index], cardWidth: cardWidth, imageHeight: imageHeight),
              );
            },
          ),
        );
      },
    );
  }
}

class _TopicCard extends StatelessWidget {
  final HomeTopicActivityBlock block;
  final double cardWidth;
  final double imageHeight;
  const _TopicCard({required this.block, required this.cardWidth, required this.imageHeight});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: block.id.isEmpty ? null : () => context.push(RouteNames.activityDetail.replaceFirst(':id', block.id)),
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 16:9 横图
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: cardWidth,
                  height: imageHeight,
                  child: (block.imageUrl != null && block.imageUrl!.isNotEmpty)
                      ? AppNetworkImage(
                          url: block.imageUrl!,
                          fit: BoxFit.cover,
                          width: cardWidth,
                          height: imageHeight,
                          memCacheWidth: cardWidth.toInt(),
                          memCacheHeight: imageHeight.toInt(),
                        )
                      : Container(width: cardWidth, height: imageHeight, color: AppColors.surfaceVariant),
                ),
              ),

              // 文字 + 按钮（按钮大小保持不变，收窄底部空白）
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 26,
                      child: Text(
                        block.title,
                        style: const TextStyle(color: Color(0xFF333333), fontSize: 11, fontWeight: FontWeight.w600, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Container(
                        width: 68,
                        height: 22, // 按钮大小保持不变
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFFF2105), width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '立即报名',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFFF2105)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
