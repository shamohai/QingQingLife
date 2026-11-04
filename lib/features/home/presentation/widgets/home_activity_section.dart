import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../data/models/weimeng_activity_location.dart' show buildWeimengActivityUri;
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/widgets/app_image.dart';

/// 首页线上活动模块：固定两列，卡片按图片原始比例自适应高度。
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
          _buildGrid(context, blocks),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<HomeActivityBlock> blocks) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
        final visibleBlocks = blocks.take(2).toList();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < visibleBlocks.length; index++) ...[
              if (index > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActivityCard(block: visibleBlocks[index], width: itemWidth),
              ),
            ],
            if (visibleBlocks.length == 1) SizedBox(width: itemWidth),
          ],
        );
      },
    );
  }
}

class _ActivityCard extends ConsumerStatefulWidget {
  final HomeActivityBlock block;
  final double width;
  const _ActivityCard({required this.block, required this.width});

  @override
  ConsumerState<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends ConsumerState<_ActivityCard> {
  static final Map<String, double> _resolvedAspectRatios = <String, double>{};

  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;
  bool _isInteracting = false;
  bool _isOpeningActivity = false;

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
    final images = _images;
    _pageController = PageController(initialPage: images.length > 1 ? images.length * 1000 : 0);
    if (images.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (_images.length <= 1 || _isInteracting) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (!_pageController.hasClients || _images.isEmpty) return;
      if (_pageController.position.isScrollingNotifier.value) return;
      final nextPage = (_pageController.page ?? _pageController.initialPage.toDouble()).round() + 1;
      _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
    final imageUrl = images.isNotEmpty ? images.first : null;
    if (imageUrl != null) _resolveImageAspectRatio(imageUrl);
    final aspectRatio = imageUrl == null ? 1.0 : (_resolvedAspectRatios[imageUrl] ?? 1.0);
    final height = widget.width / aspectRatio;
    final isTall = height > 200;

    return InkWell(
      onTap: () => _openActivity(context),
      borderRadius: BorderRadius.circular(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: widget.width,
          height: height,
          child: Stack(
            children: [
              // 按图片固有宽高比布局，避免固定高度裁切活动图。
              SizedBox(
                width: widget.width,
                height: height,
                child: images.isEmpty
                    ? Container(color: AppColors.surfaceVariant, width: widget.width, height: height)
                    : images.length == 1
                    ? AppNetworkImage(url: images.first, fit: BoxFit.fill, width: widget.width, height: height)
                    : Listener(
                        onPointerDown: (_) {
                          _isInteracting = true;
                          _timer?.cancel();
                        },
                        onPointerUp: (_) {
                          _isInteracting = false;
                          _startAutoPlay();
                        },
                        onPointerCancel: (_) {
                          _isInteracting = false;
                          _startAutoPlay();
                        },
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            if (images.length < 2) return;
                            setState(() {
                              _currentIndex = index % images.length;
                            });
                            _startAutoPlay();
                          },
                          itemBuilder: (context, index) {
                            return AppNetworkImage(url: images[index % images.length], fit: BoxFit.fill, width: widget.width, height: height);
                          },
                        ),
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
      ),
    );
  }

  void _resolveImageAspectRatio(String url) {
    if (_resolvedAspectRatios.containsKey(url)) return;

    final ImageProvider imageProvider = url.startsWith('assets/') ? AssetImage(url) : NetworkImage(url);
    final stream = imageProvider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (imageInfo, synchronousCall) {
        final image = imageInfo.image;
        if (image.height > 0) {
          _resolvedAspectRatios[url] = image.width / image.height;
          if (mounted) setState(() {});
        }
        stream.removeListener(listener);
        imageInfo.dispose();
      },
      onError: (error, stackTrace) {
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
  }

  Future<void> _openActivity(BuildContext context) async {
    if (_isOpeningActivity) return;
    final path = widget.block.actionUrl?.trim() ?? '';
    if (path.isEmpty) return;

    final baseUri = Uri.tryParse(path);
    if (baseUri == null || (baseUri.scheme != 'http' && baseUri.scheme != 'https') || baseUri.host.isEmpty) return;

    final isDrinkMap = widget.block.id == 'drinkmapactivity';
    final isDrinkRank = widget.block.id == 'drinkrankactivity';
    final isWeimengActivity = isDrinkMap || isDrinkRank;

    var activityUri = baseUri;
    if (isWeimengActivity) {
      setState(() => _isOpeningActivity = true);
      try {
        final response = await ref.read(productRepositoryProvider).getWeimengActivityLocation();
        if (!mounted) return;
        if (!response.success || response.data == null) {
          _showActivityError(response.message);
          return;
        }
        activityUri = buildWeimengActivityUri(baseUri, response.data!, includeArea: isDrinkMap);
      } on Exception {
        if (mounted) _showActivityError();
        return;
      } finally {
        if (mounted) setState(() => _isOpeningActivity = false);
      }
    }

    if (!mounted) return;
    debugPrint('线上活动拼接后的 WebView URL: $activityUri');
    if (kIsWeb) {
      await launchUrl(activityUri, webOnlyWindowName: '_blank');
      return;
    }

    final route = Uri(path: RouteNames.activityWebView, queryParameters: {'url': activityUri.toString()});
    this.context.push(route.toString());
  }

  void _showActivityError([String message = '活动暂时无法打开，请稍后重试']) {
    final displayMessage = message.trim().isEmpty ? '活动暂时无法打开，请稍后重试' : message;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(displayMessage)));
  }
}
