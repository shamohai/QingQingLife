import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';

/// 积分商城 Banner（全宽插画，可轮播，浮在页面顶部）
class PointsBanner extends StatefulWidget {
  final String imageUrl;
  final double height;
  final List<String>? imageUrls;

  const PointsBanner({
    super.key,
    required this.imageUrl,
    this.height = 450,
    this.imageUrls,
  });

  @override
  State<PointsBanner> createState() => _PointsBannerState();
}

class _PointsBannerState extends State<PointsBanner> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls != null && widget.imageUrls!.isNotEmpty
        ? widget.imageUrls!
        : [widget.imageUrl];

    return Stack(
      children: [
        // 1. Banner 图片层
        SizedBox(
          height: widget.height,
          child: urls.length > 1
              ? PageView.builder(
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, index) => AppNetworkImage(
                    url: urls[index % urls.length],
                    fit: BoxFit.cover,
                  ),
                )
              : AppNetworkImage(
                  url: widget.imageUrl,
                  fit: BoxFit.cover,
                ),
        ),
        // 2. 底部渐变蒙层（测试用：设为明显的红色）
        Positioned(
          left: 0,
          right: 0,
          bottom: -20,
          height: 110,
          child: Container(
            color: Colors.red.withValues(alpha: 0.8), // 强制测试颜色
          ),
        ),
        // 3. 指示器层
        Positioned(
          left: 0,
          right: 0,
          bottom: 24, // 向上偏移以避开蒙层下部
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              urls.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentIndex == index ? 23 : 6,
                height: 2,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? const Color(0xFFFF0088FF)
                      : Colors.white,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
