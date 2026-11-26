import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_image.dart';
import '../../data/models/service_product_detail_model.dart';

/// 积分商城服务商品详情 — Hero 区域
///
/// 包含真实设计轮播背景图、半透明返回胶囊按钮（使用设计稿 PNG 图标），
/// 以及底部渐变遮罩过渡。
class HeroSection extends StatefulWidget {
  final ServiceProductDetail product;
  final VoidCallback onBack;
  final VoidCallback onShare;

  const HeroSection({super.key, required this.product, required this.onBack, required this.onShare});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  bool _isInteracting = false;

  /// 图片 url -> 高宽比（height / width），图片加载完成后记录，用于按真实比例展示
  final Map<String, double> _aspectRatios = {};

  List<String> get _images => widget.product.carouselImages.isNotEmpty ? widget.product.carouselImages : [];

  @override
  void initState() {
    super.initState();
    final images = _images;
    _pageController = PageController(initialPage: images.length > 1 ? images.length * 1000 : 0);
    for (final url in images) {
      _resolveAspectRatio(url);
    }
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant HeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final url in _images) {
      _resolveAspectRatio(url);
    }
  }

  void _resolveAspectRatio(String url) {
    final normalized = normalizeImageUrl(url);
    if (normalized == null || normalized.startsWith('assets/') || _aspectRatios.containsKey(url)) return;
    final stream = CachedNetworkImageProvider(normalized).resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      stream.removeListener(listener);
      final width = info.image.width;
      if (!mounted || width == 0) return;
      setState(() => _aspectRatios[url] = info.image.height / width);
    }, onError: (_, _) => stream.removeListener(listener));
    stream.addListener(listener);
  }

  /// 轮播区域高度：宽度撑满屏幕，高度按当前图片真实比例计算，保证图片完整显示
  double _carouselHeight(BuildContext context) {
    final images = _images;
    if (images.isEmpty) return 340;
    final ratio = _aspectRatios[images[_currentPage % images.length]];
    if (ratio == null) return 340;
    return MediaQuery.sizeOf(context).width * ratio;
  }

  void _startTimer() {
    _timer?.cancel();
    if (_images.length <= 1 || _isInteracting) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (!_pageController.hasClients || _images.isEmpty) return;
      if (_pageController.position.isScrollingNotifier.value) return;
      final nextPage = (_pageController.page ?? _pageController.initialPage.toDouble()).round() + 1;
      _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
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
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final images = _images;

    return Stack(
      children: [
        // 1. 真实设计背景轮播图（宽度撑满，高度适当压缩以适配老旧安卓机屏幕）
        SizedBox(
          height: _carouselHeight(context),
          child: images.isEmpty
              ? Container(color: Colors.grey[200])
              : images.length == 1
              ? AppNetworkImage(url: images.first, fit: BoxFit.fitWidth, width: double.infinity)
              : Listener(
                  onPointerDown: (_) {
                    _isInteracting = true;
                    _timer?.cancel();
                  },
                  onPointerUp: (_) {
                    _isInteracting = false;
                    _startTimer();
                  },
                  onPointerCancel: (_) {
                    _isInteracting = false;
                    _startTimer();
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      if (images.length < 2) return;
                      setState(() {
                        _currentPage = index % images.length;
                      });
                      _startTimer();
                    },
                    itemBuilder: (context, index) {
                      return AppNetworkImage(url: images[index % images.length], fit: BoxFit.fitWidth, width: double.infinity);
                    },
                  ),
                ),
        ),

        // 2. 返回按钮
        Positioned(
          top: statusBarHeight + 4,
          left: 16,
          child: Material(
            color: const Color(0x4D000000),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              tooltip: '返回',
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ),
        ),

        // 3. 右上角分享按钮，与返回按钮保持相同的顶部安全区偏移和尺寸。
        Positioned(
          top: statusBarHeight + 4,
          right: 16,
          child: Material(
            color: const Color(0x4D000000),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              tooltip: '分享',
              onPressed: widget.onShare,
              icon: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ),
        ),

        // 4. 底部渐变遮罩：平滑过渡到白色卡片区域
        // Positioned(
        //   left: 0,
        //   right: 0,
        //   bottom: -30,
        //   height: 120,
        //   child: Container(
        //     decoration: const BoxDecoration(
        //       gradient: LinearGradient(
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter,
        //         colors: [Color(0x0D000000), Color(0xFFF3F5F7)],
        //       ),
        //     ),
        //   ),
        // ),

        // 5. 指示器（锚点）- 移动到顶层以确保不被遮罩覆盖（多于1张图时才显示）
        if (images.length > 1)
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: _currentPage == index ? const Color(0xFF0088FF) : Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
