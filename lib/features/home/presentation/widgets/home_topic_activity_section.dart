import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/widgets/app_image.dart';

/// 线下活动模块（整体左右滑动，严格3行结构：第1行图片，第2行文字，第3行居中按钮）
class HomeTopicActivitySection extends StatelessWidget {
  final List<HomeTopicActivityBlock> blocks;
  const HomeTopicActivitySection({super.key, required this.blocks});

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(14)), // 设计稿 14px 圆角
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Image.asset(
                'assets/images/home/kingkong_member.png',
                width: 16,
                height: 16,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 16,
                  height: 16,
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
          // 整体左右滑动列表
          _buildHorizontalList(context, blocks),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<HomeTopicActivityBlock> blocks) {
    return SizedBox(
      height: 215, // 卡片总高度
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: blocks.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < blocks.length - 1 ? AppSpacing.sm : 0),
            child: _TopicCard(block: blocks[index]),
          );
        },
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final HomeTopicActivityBlock block;
  const _TopicCard({required this.block});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 215, // 卡片宽度
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14), // 14px 圆角
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisSize: MainAxisSize.min,
        children: [
          // 第 1 行：图片
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            child: SizedBox(
              width: 137,
              height: 120,
              child: (block.imageUrl != null && block.imageUrl!.isNotEmpty)
                  ? AppNetworkImage(url: block.imageUrl!, fit: BoxFit.cover, width: 137, height: 120)
                  : Container(color: AppColors.surfaceVariant, width: 137, height: 120),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 第 2 行：文字
                Text(
                  block.title,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 第 3 行：立即参与 按钮 (居中)
                Center(
                  child: Container(
                    width: 60,
                    height: 19,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFFF2105), width: 1.0),
                      borderRadius: BorderRadius.circular(67),
                    ),
                    child: const Center(
                      child: Text(
                        '立即参与',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFF2105),
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
