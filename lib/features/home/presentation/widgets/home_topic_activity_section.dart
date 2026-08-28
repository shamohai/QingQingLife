import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/widgets/app_image.dart';
import 'home_product_card.dart';

class HomeTopicActivitySection extends StatelessWidget {
  final List<HomeTopicActivityBlock> blocks;
  const HomeTopicActivitySection({super.key, required this.blocks});
  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg), child: _buildGrid(context, blocks));
  }
  Widget _buildGrid(BuildContext context, List<HomeTopicActivityBlock> blocks) {
    final mainBlock = blocks.isNotEmpty ? blocks[0] : null;
    final rightBlocks = blocks.length >= 2 ? blocks.sublist(1, 3) : [];
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (mainBlock != null) Expanded(flex: 2, child: _TopicMainCard(block: mainBlock)),
      if (mainBlock != null) const SizedBox(width: AppSpacing.sm),
      if (rightBlocks.isNotEmpty) Expanded(flex: 1, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rightBlocks.map((b) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm), child: _TopicSideCard(block: b))).toList())),
    ]);
  }
}

class _TopicMainCard extends StatelessWidget {
  final HomeTopicActivityBlock block;
  const _TopicMainCard({required this.block});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(AppRadius.lg), child: Stack(children: [
      if (block.imageUrl != null && block.imageUrl!.isNotEmpty)
        AppNetworkImage(url: block.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: 160.0)
      else
        Container(color: AppColors.surfaceVariant, width: double.infinity, height: 160.0),
      Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withAlpha(77)])))),
      Positioned(bottom: 14.0, left: 12.0, right: 12.0, child: Text(block.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1))]), maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]));
  }
}

class _TopicSideCard extends StatelessWidget {
  final HomeTopicActivityBlock block;
  const _TopicSideCard({required this.block});
  @override
  Widget build(BuildContext context) {
    if (block.product != null) {
      return SizedBox(height: 160, child: HomeProductCard(product: block.product!, compact: true));
    }
    return ClipRRect(borderRadius: BorderRadius.circular(AppRadius.lg), child: Stack(children: [
      if (block.imageUrl != null && block.imageUrl!.isNotEmpty)
        AppNetworkImage(url: block.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: 74.0)
      else
        Container(color: AppColors.surfaceVariant, width: double.infinity, height: 74.0),
      Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withAlpha(77)])))),
      Positioned(bottom: 10.0, left: 12.0, right: 12.0, child: Text(block.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1))]), maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]));
  }
}