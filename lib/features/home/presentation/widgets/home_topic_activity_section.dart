import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/widgets/app_image.dart';

/// 线下活动模块（对齐蓝湖设计稿）
/// 设计稿：白色卡片，"线下活动" + 副标题，3张卡片横向（137x228），"立即参与" 红色描边按钮
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
          // 3张卡片横向排列
          _buildGrid(context, blocks),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<HomeTopicActivityBlock> blocks) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (index) {
        if (index >= blocks.length) {
          return Expanded(
            child: Container(
              height: 228, // 设计稿 228px 高度
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(14)),
              child: const Center(
                child: Text('暂无活动', style: TextStyle(color: Colors.grey)),
              ),
            ),
          );
        }
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? AppSpacing.sm : 0),
            child: _TopicCard(block: blocks[index]),
          ),
        );
      }),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final HomeTopicActivityBlock block;
  const _TopicCard({required this.block});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14), // 设计稿 14px 圆角
      child: Stack(
        children: [
          // 背景图 137x228
          SizedBox(
            width: double.infinity,
            height: 228, // 设计稿 228px 高度
            child: (block.imageUrl != null && block.imageUrl!.isNotEmpty)
                ? AppNetworkImage(url: block.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: 228)
                : Container(color: AppColors.surfaceVariant, width: double.infinity, height: 228),
          ),
          // 渐变遮罩
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withAlpha(180)]),
              ),
            ),
          ),
          // 底部内容
          Positioned(
            bottom: 14,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  block.title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // "立即参与" 红色描边胶囊按钮
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: const Color(0xFFE53935), width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      '立即参与',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFE53935)),
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
