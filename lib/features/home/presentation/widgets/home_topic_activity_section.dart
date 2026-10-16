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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(14))),
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
          // 整体左右滑动列表
          _buildHorizontalList(context, blocks),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<HomeTopicActivityBlock> blocks) {
    return SizedBox(
      height: 258, // 188(图) + 文字区 + 按钮 + padding ≈ 258
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
      width: 137,
      decoration: BoxDecoration(
        color: Colors.white, // 和模块白色背景一致
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 完整图片 137×188
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            child: SizedBox(
              width: 137,
              height: 188,
              child: (block.imageUrl != null && block.imageUrl!.isNotEmpty)
                  ? AppNetworkImage(url: block.imageUrl!, fit: BoxFit.cover, width: 137, height: 188)
                  : Container(width: 137, height: 188, color: AppColors.surfaceVariant),
            ),
          ),

          // 文字 + 按钮（在图片下方）
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.title,
                  style: const TextStyle(color: Color(0xFF333333), fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Center(
                  child: Container(
                    width: 68,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFFF2105), width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '立即参与',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFFF2105)),
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
