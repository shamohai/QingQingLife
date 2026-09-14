import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';

/// 积分商城 Banner（全宽插画，可轮播，浮在页面顶部）
class PointsBanner extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final urls = imageUrls != null && imageUrls!.isNotEmpty
        ? imageUrls!
        : [imageUrl];

    return Stack(
      fit: StackFit.expand,
      children: [
        if (urls.length > 1)
          PageView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => AppNetworkImage(
              url: urls[index % urls.length],
              fit: BoxFit.cover,
            ),
          )
        else
          AppNetworkImage(
            url: imageUrl,
            fit: BoxFit.cover,
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              urls.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == 0 ? 16 : 6,
                height: 4,
                decoration: BoxDecoration(
                  color: index == 0
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
