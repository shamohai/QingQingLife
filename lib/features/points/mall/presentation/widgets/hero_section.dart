import 'dart:async';

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

  List<String> get _images => widget.product.carouselImages.isNotEmpty ? widget.product.carouselImages : [];

  @override
  void initState() {
    super.initState();
    final images = _images;
    _pageController = PageController(initialPage: images.length > 1 ? images.length * 1000 : 0);
    _startTimer();
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
        // 1. 真实设计背景轮播图（439×439，覆盖整个 Hero 区域）
        SizedBox(
          height: 389,
          child: images.isEmpty
              ? Container(color: Colors.grey[200])
              : images.length == 1
              ? AppNetworkImage(url: images.first, fit: BoxFit.cover, width: double.infinity)
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
                      return AppNetworkImage(url: images[index % images.length], fit: BoxFit.cover, width: double.infinity);
                    },
                  ),
                ),
        ),

        // 2. 返回胶囊按钮（设计稿：margin-top=50, margin-left=24）
        Positioned(
          top: statusBarHeight + 4,
          child: Container(
            height: 44,
            decoration: BoxDecoration(color: const Color(0x4D000000), borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                  onPressed: widget.onBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text(
                    '商品详情',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. 右上角分享按钮，与返回胶囊保持相同的顶部安全区偏移。
        Positioned(
          top: statusBarHeight + 2,
          right: 16,
          child: Material(
            color: const Color(0x4D000000),
            borderRadius: BorderRadius.circular(6),
            child: IconButton(
              tooltip: '分享',
              onPressed: widget.onShare,
              icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
              constraints: const BoxConstraints(minWidth: 44, minHeight: 40),
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
