import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_image.dart';
import '../../data/models/service_product_detail_model.dart';

/// 积分商城服务商品详情 — Hero 区域
///
/// 包含真实设计轮播背景图、半透明返回胶囊按钮（使用设计稿 PNG 图标），
/// 以及底部渐变遮罩过渡。
class HeroSection extends StatefulWidget {
  final ServiceProductDetail product;
  final VoidCallback onBack;

  const HeroSection({super.key, required this.product, required this.onBack});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  List<String> get _images => widget.product.carouselImages.isNotEmpty
      ? widget.product.carouselImages
      : [
          'assets/images/service/service_product_hero_bg.png',
          'assets/images/service/service_product_hero_bg2.png',
          'assets/images/service/service_product_hero_bg3.png',
        ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final list = _images;
        if (list.isNotEmpty) {
          final nextPage = (_currentPage + 1) % list.length;
          _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      }
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
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return AppNetworkImage(
                url: images[index],
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
        ),

        // 2. 返回胶囊按钮（设计稿：margin-top=50, margin-left=24）
        Positioned(
          top: statusBarHeight + 2,
          child: Container(
            height: 40,
            decoration: BoxDecoration(color: const Color(0x4D000000), borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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

        // 3. 底部渐变遮罩：平滑过渡到白色卡片区域
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

        // 4. 指示器（锚点）- 移动到顶层以确保不被遮罩覆盖（多于1张图时才显示）
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
