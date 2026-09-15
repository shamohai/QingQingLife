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
      clipBehavior: Clip.none, // ← 关键！允许子组件超出边界
      children: [
        // 1. Banner 图片层
        SizedBox(
          height: widget.height,
          child: urls.length > 1
              ? PageView.builder(
                  itemCount: urls.length,
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
          bottom: -30,
          height: 120,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x0D9D9D9D), // startColor #0d9d9d9
                  Color(0xFFF3F5F7), // endColor #fff3f5f7
                ],
              ),
            ),
          ),
        ),
        // 3. 指示器（蒙层上部）
        Positioned(
          left: 0,
          right: 0,
          bottom: 80, // 位置继续用你调好的
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              urls.length,
                  (index) {
                final bool isActive = _currentIndex == index;
                return Container(
                  // 去掉 margin，或者设为 0，实现紧挨
                  width: 23, // 长度一致
                  height: 2,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF0088FF) // 选中
                        : Colors.white,           // 未选中
                    borderRadius: BorderRadius.zero,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
