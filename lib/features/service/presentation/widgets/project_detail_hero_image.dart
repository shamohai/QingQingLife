import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';

/// 预约项目详情 — Hero 主图区域
///
/// 支持本地 asset 和网络 URL 两种来源：
/// - 以 http 开头的 [heroAsset] 视为网络图片，使用 AppNetworkImage
/// - 否则视为本地 asset，使用 Image.asset
/// - 空字符串时显示占位图
///
/// 尺寸固定 height=242（marginTop 13 + 图片 180 + 底部 padding 49），
/// 图片宽全屏减去左右各 14dp，高 180dp，cover 填充。
class ProjectDetailHeroImage extends StatefulWidget {
  final String heroAsset;
  final List<String> imageUrls;
  final double horizontalPadding;
  final double? aspectRatio;

  const ProjectDetailHeroImage({super.key, required this.heroAsset, this.imageUrls = const [], this.horizontalPadding = AppSpacing.lg, this.aspectRatio});

  @override
  State<ProjectDetailHeroImage> createState() => _ProjectDetailHeroImageState();
}

class _ProjectDetailHeroImageState extends State<ProjectDetailHeroImage> with WidgetsBindingObserver {
  static const _autoplayInterval = Duration(seconds: 3);
  static const _transitionDuration = Duration(milliseconds: 400);

  late final PageController _pageController;
  Timer? _autoplayTimer;
  bool _isInteracting = false;

  List<String> get _images {
    final imageUrls = widget.imageUrls.where((url) => url.trim().isNotEmpty).toList(growable: false);
    return imageUrls.isNotEmpty ? imageUrls : [widget.heroAsset];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _images.length > 1 ? _images.length * 1000 : 0);
    WidgetsBinding.instance.addObserver(this);
    _startAutoplay();
  }

  @override
  void didUpdateWidget(covariant ProjectDetailHeroImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.imageUrls, widget.imageUrls) || oldWidget.heroAsset != widget.heroAsset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(_images.length > 1 ? _images.length * 1000 : 0);
        }
      });
      _startAutoplay();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startAutoplay();
    } else {
      _autoplayTimer?.cancel();
    }
  }

  void _startAutoplay() {
    _autoplayTimer?.cancel();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (_images.length < 2 || _isInteracting || (lifecycle != null && lifecycle != AppLifecycleState.resumed)) return;
    _autoplayTimer = Timer.periodic(_autoplayInterval, (_) {
      if (!mounted || !_pageController.hasClients || !TickerMode.valuesOf(context).enabled || _pageController.position.isScrollingNotifier.value) {
        return;
      }
      final nextPage = (_pageController.page ?? _pageController.initialPage.toDouble()).round() + 1;
      _pageController.animateToPage(nextPage, duration: _transitionDuration, curve: Curves.easeInOut);
    });
  }

  void _endInteraction() {
    _isInteracting = false;
    _startAutoplay();
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Image.asset('assets/images/service/service_project_hero.png', width: double.infinity, fit: BoxFit.cover);
    }
    if (imageUrl.startsWith('http')) {
      return AppNetworkImage(url: imageUrl, width: double.infinity, fit: BoxFit.cover);
    }
    return Image.asset(imageUrl, width: double.infinity, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    final Widget imageWidget = images.length < 2
        ? _buildImage(images.first)
        : Listener(
            onPointerDown: (_) {
              _isInteracting = true;
              _autoplayTimer?.cancel();
            },
            onPointerUp: (_) => _endInteraction(),
            onPointerCancel: (_) => _endInteraction(),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (_) => _startAutoplay(),
              itemBuilder: (context, index) => _buildImage(images[index % images.length]),
            ),
          );

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          child: widget.aspectRatio == null ? imageWidget : AspectRatio(aspectRatio: widget.aspectRatio!, child: imageWidget),
        ),
      ),
    );
  }
}
