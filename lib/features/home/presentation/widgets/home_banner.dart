import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';

/// 首页轮播 Banner
/// 设计稿：414x220，圆角 14px，PageView 带指示点
class HomeBanner extends StatefulWidget {
  final List<String> imageUrls;
  const HomeBanner({super.key, required this.imageUrls});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  late PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14), // 设计稿 14px 边距
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14), // 设计稿 14px 圆角
            child: SizedBox(
              height: 220, // 设计稿 220px 高度
              width: double.infinity,
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) => AppNetworkImage(url: widget.imageUrls[index], fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 指示点
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              widget.imageUrls.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == index ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(color: _currentPage == index ? Colors.white : Colors.white.withAlpha(100), borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
