import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/widgets/app_image.dart';

/// 线上活动模块（对齐蓝湖设计稿）
/// 设计稿：白色卡片，"线上活动" + 副标题，左侧 1 张大卡片 (294)，右侧上下 2 张小卡片 (142+142)
class HomeActivitySection extends StatelessWidget {
  final List<HomeActivityBlock> blocks;
  const HomeActivitySection({super.key, required this.blocks});

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
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
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 24,
                  height: 24,
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
          // 左右布局：左侧 1 张大卡片，右侧上下 2 张小卡片
          _buildGrid(context, blocks),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<HomeActivityBlock> blocks) {
    final leftBlock = blocks.isNotEmpty ? blocks[0] : null;
    final topRightBlock = blocks.length > 1 ? blocks[1] : null;
    final bottomRightBlock = blocks.length > 2 ? blocks[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧大卡片 (高度 294)
        Expanded(
          child: leftBlock != null ? _ActivityCard(block: leftBlock, height: 294) : Container(height: 294, color: Colors.grey[200]),
        ),
        const SizedBox(width: AppSpacing.sm),
        // 右侧上下两张卡片 (总高 294, 中间间距 10, 每张高 142)
        Expanded(
          child: Column(
            children: [
              topRightBlock != null ? _ActivityCard(block: topRightBlock, height: 142) : Container(height: 142, color: Colors.grey[200]),
              const SizedBox(height: 10),
              bottomRightBlock != null ? _ActivityCard(block: bottomRightBlock, height: 142) : Container(height: 142, color: Colors.grey[200]),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final HomeActivityBlock block;
  final double height;
  const _ActivityCard({required this.block, this.height = 294});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  List<String> get _images {
    if (widget.block.imageUrls != null && widget.block.imageUrls!.isNotEmpty) {
      return widget.block.imageUrls!;
    }
    if (widget.block.imageUrl != null && widget.block.imageUrl!.isNotEmpty) {
      return [widget.block.imageUrl!];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (_images.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (_images.isEmpty) return;
      final nextIndex = (_currentIndex + 1) % _images.length;
      _pageController.animateToPage(nextIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    final isTall = widget.height > 200;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14), // 设计稿 14px 圆角
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // 背景图 / 轮播图
            SizedBox(
              width: double.infinity,
              height: widget.height,
              child: images.isEmpty
                  ? Container(color: AppColors.surfaceVariant, width: double.infinity, height: widget.height)
                  : images.length == 1
                  ? AppNetworkImage(url: images.first, fit: BoxFit.cover, width: double.infinity, height: widget.height)
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return AppNetworkImage(url: images[index], fit: BoxFit.cover, width: double.infinity, height: widget.height);
                      },
                    ),
            ),
            // 渐变蒙层：从中间50%位置到图片底部
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment(0.0, 0.0), // 中间 50% 位置
                    end: Alignment.bottomCenter,
                    colors: [Color(0x0D9D9D9D), Color(0xFF213775)],
                  ),
                ),
              ),
            ),
            // 自定义指示器：右上角，图片数量 > 1 时显示
            if (images.length > 1)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(images.length, (index) {
                    final isSelected = index == _currentIndex;
                    return Container(
                      width: 8,
                      height: 4,
                      margin: const EdgeInsets.only(left: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0088FF) : Colors.white,
                        borderRadius: BorderRadius.zero, // 直角 (0dp 圆角)
                      ),
                    );
                  }),
                ),
              ),
            // 底部内容
            Positioned(
              bottom: isTall ? 16 : 10,
              left: isTall ? 14 : 8,
              right: isTall ? 14 : 8,
              child: isTall
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.block.title,
                          style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 11, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        // "立即参与" 按钮样式 (71x24, 圆角 67, 白色背景, 文字 #213775 11sp)
                        Container(
                          width: 71,
                          height: 24,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(67)),
                          child: const Center(
                            child: Text(
                              '立即参与',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF213775)),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.block.title,
                            style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 9, fontWeight: FontWeight.w500, height: 1.2),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // 右侧 16x16 白色圆形带箭头按钮
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle, // 圆形按钮
                          ),
                          child: const Center(child: Icon(Icons.chevron_right, size: 10, color: Color(0xFF213775))),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
