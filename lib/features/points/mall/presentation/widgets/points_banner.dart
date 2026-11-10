import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_image.dart';

/// 积分商城 Banner（全宽插画，可轮播，浮在页面顶部）
class PointsBanner extends StatefulWidget {
  final String imageUrl;
  final double height;
  final List<String>? imageUrls;
  final Duration autoPlayInterval; // 自动轮播间隔
  final bool autoPlay; // 是否开启自动轮播

  const PointsBanner({
    super.key,
    required this.imageUrl,
    this.height = 450,
    this.imageUrls,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 3),
  });

  @override
  State<PointsBanner> createState() => _PointsBannerState();
}

class _PointsBannerState extends State<PointsBanner> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  List<String> get _urls {
    if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty) {
      return widget.imageUrls!;
    }
    return [widget.imageUrl];
  }

  @override
  void initState() {
    super.initState();
    final urls = _urls;
    _pageController = PageController(initialPage: urls.length > 1 ? urls.length * 1000 : 0);
    if (widget.autoPlay && urls.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (_urls.length <= 1) return;
    _timer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted) return;
      if (!_pageController.hasClients || _urls.isEmpty) return;
      if (_pageController.position.isScrollingNotifier.value) return;

      final nextPage = (_pageController.page ?? _pageController.initialPage.toDouble()).round() + 1;
      _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Banner 图片层
          SizedBox(
            height: widget.height,
            width: double.infinity,
            child: urls.length > 1
                ? NotificationListener<ScrollNotification>(
                    // 用户手动滑动时暂停，滑完再恢复
                    onNotification: (notification) {
                      if (notification is ScrollStartNotification) {
                        _stopAutoPlay();
                      } else if (notification is ScrollEndNotification) {
                        if (widget.autoPlay) _startAutoPlay();
                      }
                      return false;
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentIndex = i % urls.length),
                      itemBuilder: (context, index) {
                        return AppNetworkImage(url: urls[index % urls.length], fit: BoxFit.cover);
                      },
                    ),
                  )
                : AppNetworkImage(url: widget.imageUrl, fit: BoxFit.cover),
          ),

          // 2. 底部渐变蒙层
          Positioned(
            left: 0,
            right: 0,
            bottom: -30,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x0D9D9D9D), Color(0xFFF3F5F7)]),
                ),
              ),
            ),
          ),

          // 3. 指示器
          if (urls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              top: 188,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(urls.length, (index) {
                  final bool isActive = _currentIndex == index;
                  return GestureDetector(
                    onTap: () {
                      final currentCycle = (_pageController.page ?? _pageController.initialPage.toDouble()).round() ~/ urls.length;
                      final targetPage = currentCycle * urls.length + index;
                      _pageController.animateToPage(targetPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    // 💡 增加一点透明的 padding，扩大点击区域，防止指示器太细不好点
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 30 : 30,
                        height: 3,
                        decoration: BoxDecoration(color: isActive ? const Color(0xFF0088FF) : Colors.white, borderRadius: BorderRadius.zero),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
