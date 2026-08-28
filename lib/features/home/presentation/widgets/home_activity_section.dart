import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/widgets/app_image.dart';

class HomeActivitySection extends StatelessWidget {
  final List<HomeActivityBlock> blocks;
  const HomeActivitySection({super.key, required this.blocks});
  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg), child: _buildGrid(context, blocks));
  }
  Widget _buildGrid(BuildContext context, List<HomeActivityBlock> blocks) {
    final mainBlock = blocks.isNotEmpty ? blocks[0] : null;
    final rightBlocks = blocks.length >= 2 ? blocks.sublist(1, 3) : [];
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (mainBlock != null) Expanded(flex: 2, child: _ActivityCard(block: mainBlock)),
      if (mainBlock != null) const SizedBox(width: AppSpacing.sm),
      if (rightBlocks.isNotEmpty) Expanded(flex: 1, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rightBlocks.map((b) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm), child: _ActivityCard(block: b, wide: false))).toList())),
    ]);
  }
}

class _ActivityCard extends StatelessWidget {
  final HomeActivityBlock block;
  final bool wide;
  const _ActivityCard({required this.block, this.wide = true});
  @override
  Widget build(BuildContext context) {
    final height = wide ? 160.0 : 74.0;
    return ClipRRect(borderRadius: BorderRadius.circular(AppRadius.lg), child: Stack(children: [
      (block.imageUrl != null && block.imageUrl!.isNotEmpty) ? AppNetworkImage(url: block.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: height) : Container(color: AppColors.surfaceVariant, width: double.infinity, height: height),
      Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withAlpha(77)])))),
      Positioned(bottom: wide ? 14.0 : 10.0, left: 12.0, right: 12.0, child: Text(block.title, style: TextStyle(color: Colors.white, fontSize: wide ? 16 : 14, fontWeight: FontWeight.w600, shadows: [Shadow(color: Colors.black.withAlpha(77), blurRadius: 4, offset: const Offset(0, 1))]), maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]));
  }
}