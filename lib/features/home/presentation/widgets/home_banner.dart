import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_image.dart';
import '../../data/models/carousel_model.dart';

/// 首页轮播 Banner（支持自动定时滑动，兼容网络图/本地资源图，自定义指示条样式）
///
/// 点击轮播图时根据 JumpType 执行对应导航行为。
/// 设计稿：414x220，圆角 14px，带指示点与自动播放
class HomeBanner extends StatefulWidget {
  final List<CarouselBanner> banners;
  final Duration autoPlayInterval;

  const HomeBanner({super.key, required this.banners, this.autoPlayInterval = const Duration(seconds: 3)});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  late PageController _controller;
  int _currentPage = 0;
  Timer? _timer;
  bool _isInteracting = false;

  List<CarouselBanner> get _banners => widget.banners;

  @override
  void initState() {
    super.initState();
    final count = _banners.length;
    _controller = PageController(initialPage: count > 1 ? count * 1000 : 0);
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(HomeBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners != widget.banners) {
      final count = _banners.length;
      _currentPage = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) {
          _controller.jumpToPage(count > 1 ? count * 1000 : 0);
        }
      });
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (_banners.length <= 1 || _isInteracting) return;
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (!mounted) return;
      if (!_controller.hasClients || _banners.isEmpty) return;
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

  void _handleTap(int index) {
    if (index < 0 || index >= _banners.length) return;
    final banner = _banners[index];
    switch (banner.jumpType) {
      case JumpType.productDetail:
        if (banner.postData.isNotEmpty) {
          context.push(RouteNames.productDetail.replaceFirst(':id', banner.postData));
        }
        break;
      case JumpType.creditMall:
        context.push(RouteNames.pointsMall);
        break;
      case JumpType.cart:
        context.push(RouteNames.cart);
        break;
      case JumpType.orderList:
        context.push(RouteNames.orders);
        break;
      case JumpType.webView:
      case JumpType.productList:
      case JumpType.minProgram:
      case JumpType.programPage:
      case JumpType.zjProgramPage:
        if (banner.viewUrl.isNotEmpty) {
          final uri = Uri.tryParse(banner.viewUrl);
          if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
      case JumpType.none:
      default:
        break;
    }
  }

  Widget _buildImage(CarouselBanner banner) {
    final url = banner.imageUrl;
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
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
    final banners = _banners;
    if (banners.isEmpty) return const SizedBox.shrink();

    final isSingle = banners.length <= 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 220,
          width: double.infinity,
          child: Stack(
            children: [
              // PageView 轮播图（带点击手势）
              Listener(
                onPointerDown: isSingle
                    ? null
                    : (_) {
                        _isInteracting = true;
                        _timer?.cancel();
                      },
                onPointerUp: isSingle
                    ? null
                    : (_) {
                        _isInteracting = false;
                        _startAutoPlay();
                      },
                onPointerCancel: isSingle
                    ? null
                    : (_) {
                        _isInteracting = false;
                        _startAutoPlay();
                      },
                child: PageView.builder(
                  controller: _controller,
                  physics: isSingle ? const NeverScrollableScrollPhysics() : null,
                  itemCount: isSingle ? 1 : null,
                  onPageChanged: (i) {
                    if (banners.length < 2) return;
                    setState(() => _currentPage = i % banners.length);
                    _startAutoPlay();
                  },
                  itemBuilder: (context, index) {
                    final actualIndex = isSingle ? 0 : (index % banners.length);
                    final banner = banners[actualIndex];
                    return GestureDetector(
                      onTap: () => _handleTap(actualIndex),
                      child: _buildImage(banner),
                    );
                  },
                ),
              ),

              // 指示条
              if (!isSingle)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(banners.length, (index) {
                        final bool isActive = _currentPage == index;
                        return Container(
                          width: 30,
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFF0088FF) : Colors.white.withAlpha(200),
                            borderRadius: BorderRadius.zero,
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
