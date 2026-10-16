import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/widgets/app_image.dart';

/// 线上活动模块（对齐蓝湖设计稿）
/// 设计稿：白色卡片，"线上活动" + 副标题，2张大卡片并排（189x294），渐变遮罩 + "立即参与" 白色胶囊按钮
class HomeActivitySection extends StatelessWidget {
  final List<HomeActivityBlock> blocks;
  const HomeActivitySection({super.key, required this.blocks});

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
                  child: const Icon(Icons.language, size: 10, color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('线上活动', style: AppTextStyles.headlineSmall),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '(足不出户逛好店，惊喜福利线上见)',
                  style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF999999), fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 2张大卡片横向排列
          _buildGrid(context, blocks),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<HomeActivityBlock> blocks) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(2, (index) {
        if (index >= blocks.length) {
          return Expanded(
            child: Container(
              height: 294, // 设计稿 294px 高度
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(14)),
              child: const Center(
                child: Text('暂无活动', style: TextStyle(color: Colors.grey)),
              ),
            ),
          );
        }
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 0 ? AppSpacing.sm : 0),
            child: _ActivityCard(block: blocks[index]),
          ),
        );
      }),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final HomeActivityBlock block;
  const _ActivityCard({required this.block});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14), // 设计稿 14px 圆角
      child: Stack(
        children: [
          // 背景图 189x294
          SizedBox(
            width: double.infinity,
            height: 294, // 设计稿 294px 高度
            child: (block.imageUrl != null && block.imageUrl!.isNotEmpty)
                ? AppNetworkImage(url: block.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: 294)
                : Container(color: AppColors.surfaceVariant, width: double.infinity, height: 294),
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
            bottom: 16,
            left: 14,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  block.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // "立即参与" 白色胶囊按钮
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Center(
                    child: Text(
                      '立即参与',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF213775)),
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
