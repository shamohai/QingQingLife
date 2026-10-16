import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';

/// 首页轮播 Banner（支持自动定时滑动，兼容网络图/本地资源图，自定义指示条样式）
/// 设计稿：414x220，圆角 14px，带指示点与自动播放
class HomeBanner extends StatefulWidget {
  final List<String> imageUrls;
  final Duration autoPlayInterval;

  const HomeBanner({super.key, required this.imageUrls, this.autoPlayInterval = const Duration(seconds: 3)});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  late PageController _controller;
  int _currentPage = 0;
  Timer? _timer;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    final urls = widget.imageUrls;
    _controller = PageController(initialPage: urls.length > 1 ? urls.length * 1000 : 0);
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(HomeBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls != widget.imageUrls) {
      final urls = widget.imageUrls;
      _currentPage = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) {
          _controller.jumpToPage(urls.length > 1 ? urls.length * 1000 : 0);
        }
      });
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.imageUrls.length <= 1 || _isInteracting) return;
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (!mounted) return;
      if (!_controller.hasClients || widget.imageUrls.isEmpty) return;
      if (_controller.position.isScrollingNotifier.value) return;
      final nextPage = (_controller.page ?? _controller.initialPage.toDouble()).round() + 1;
      _controller.animateToPage(nextPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildImage(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
        ),
      );
    }
    return AppNetworkImage(url: url, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    if (urls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14), // 设计稿 14px 边距
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14), // 设计稿 14px 圆角
        child: SizedBox(
          height: 220, // 设计稿 220px 高度
          width: double.infinity,
          child: Stack(
            children: [
              // PageView 轮播图
              Listener(
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
                  controller: _controller,
                  onPageChanged: (i) {
                    if (urls.length < 2) return;
                    setState(() => _currentPage = i % urls.length);
                    _startAutoPlay(); // 手动滑动后重置定时器
                  },
                  itemBuilder: (context, index) => _buildImage(urls[index % urls.length]),
                ),
              ),

              // 指示条：直接浮在 Banner 图片内，距离底部 20px 处，紧密无间隙
              Positioned(
                bottom: 16, // 距离 Banner 图片底部 20px
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(urls.length, (index) {
                      final bool isActive = _currentPage == index;
                      return GestureDetector(
                        onTap: () {
                          final currentCycle = (_controller.page ?? _controller.initialPage.toDouble()).round() ~/ urls.length;
                          final targetPage = currentCycle * urls.length + index;
                          _controller.animateToPage(targetPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6), // 无水平间隙，保留垂直触控热区
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 30,
                            height: 3,
                            decoration: BoxDecoration(color: isActive ? const Color(0xFF0088FF) : Colors.white.withAlpha(200), borderRadius: BorderRadius.zero),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
