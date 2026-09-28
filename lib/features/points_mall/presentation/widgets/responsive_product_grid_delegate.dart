import 'package:flutter/rendering.dart';

/// 自定义 SliverGridDelegate：卡片宽度根据实际可用宽度动态计算
///
/// 设计基准 440dp 下每卡 200dp，gap=12dp。
class ResponsiveProductGridDelegate extends SliverGridDelegate {
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  static const double _designAspect = 200 / 308;

  const ResponsiveProductGridDelegate({
    this.crossAxisSpacing = 10,
    this.mainAxisSpacing = 10,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double availableWidth = constraints.crossAxisExtent - crossAxisSpacing;
    final double cardWidth = availableWidth / 2;
    final double cardHeight = cardWidth / _designAspect;

    return SliverGridRegularTileLayout(
      crossAxisCount: 2,
      mainAxisStride: cardHeight + mainAxisSpacing,
      crossAxisStride: cardWidth + crossAxisSpacing,
      childMainAxisExtent: cardHeight,
      childCrossAxisExtent: cardWidth,
      reverseCrossAxis: false,
    );
  }

  @override
  bool shouldRelayout(covariant ResponsiveProductGridDelegate oldDelegate) =>
      crossAxisSpacing != oldDelegate.crossAxisSpacing ||
      mainAxisSpacing != oldDelegate.mainAxisSpacing;
}