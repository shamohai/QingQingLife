import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';

/// 积分商城轮播图组件（支持自动轮播 + 圆点指示器）
class PointsBannerCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final Duration autoScrollDuration;

  const PointsBannerCarousel({
    super.key,
    required this.imageUrls,
    this.height = 160,
    this.autoScrollDuration = const Duration(seconds: 4),
  });

  @override
  State<PointsBannerCarousel> createState() => _PointsBannerCarouselState();
}

class _PointsBannerCarouselState extends State<PointsBannerCarousel> {
  late PageController _controller;
  int currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.imageUrls.length <= 1) return;
    
    _timer = Timer.periodic(widget.autoScrollDuration, (timer) {
      if (_controller.hasClients && widget.imageUrls.isNotEmpty) {
        final nextIndex = (currentPage + 1) % widget.imageUrls.length;
        _controller.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    if (urls.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => currentPage = i),
              itemCount: urls.length,
              itemBuilder: (context, index) => CachedNetworkImage(
                imageUrl: urls[index % urls.length],
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.image_not_supported_outlined, size: 40, color: AppColors.outline),
                ),
              ),
            ),
          ),
        ),
        if (urls.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(urls.length, (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: currentPage == index ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: currentPage == index ? AppColors.primary : const Color(0xFFC4C8BF),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )),
          ),
        ],
      ],
    );
  }
}