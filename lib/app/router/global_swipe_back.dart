import 'package:flutter/widgets.dart';

/// 全局右滑返回：在任意页面向右滑动时执行 [onSwipeBack]。
///
/// 只在 [canSwipeBack] 为 true 时触发，因此没有上一页时右滑无任何效果。
/// 只识别横向拖拽，纵向滚动不受影响；页面内部的横向滚动组件会先参与手势竞争，
/// 因此在横向滚动区域内右滑可能不会触发返回。
class GlobalSwipeBack extends StatelessWidget {
  const GlobalSwipeBack({super.key, required this.canSwipeBack, required this.onSwipeBack, required this.child});

  final bool Function() canSwipeBack;
  final VoidCallback onSwipeBack;
  final Widget child;

  /// 判定为有效滑动的最小速度（逻辑像素/秒）
  static const double _minVelocity = 300;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > _minVelocity && canSwipeBack()) {
          onSwipeBack();
        }
      },
      child: child,
    );
  }
}
