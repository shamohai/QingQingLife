import 'package:flutter/cupertino.dart';

/// 全屏右滑返回的页面，替代 [MaterialPage] 用于二级页、三级页等非 Tab 页面。
///
/// 页面可在任意位置向右拖动，跟手移动并露出上一页；松手后超过半屏或速度足够快则返回，否则回弹。
/// 没有上一页（或处于 Tab 根页面）时不响应手势。
/// 动效使用 Flutter 公开的 [CupertinoPageTransition]，与 iOS 原生返回一致。
class SwipeBackPage<T> extends Page<T> {
  const SwipeBackPage({required this.child, super.key, super.name, super.arguments, super.restorationId});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => _SwipeBackRoute<T>(this);
}

class _SwipeBackRoute<T> extends PageRoute<T> {
  _SwipeBackRoute(SwipeBackPage<T> page) : super(settings: page);

  Widget get _child => (settings as SwipeBackPage<T>).child;

  /// 拖动完成后的动画时长（与 Cupertino 保持一致）
  static const Duration _dropDuration = Duration(milliseconds: 350);

  /// 页面推入/弹出的动画时长（与 Cupertino 保持一致）
  static const Duration _transitionDuration = Duration(milliseconds: 500);

  /// 视为快速滑动的速度阈值（屏幕宽度/秒）
  static const double _minFlingVelocity = 1.0;

  AnimationController? _dragController;
  NavigatorState? _dragNavigator;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Duration get reverseTransitionDuration => _transitionDuration;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => previousRoute is PageRoute;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Semantics(scopesRoute: true, explicitChildNodes: true, child: _child);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: popGestureInProgress,
      child: _SwipeBackGesture(onStart: _onDragStart, onUpdate: _onDragUpdate, onEnd: _onDragEnd, child: child),
    );
  }

  bool get _canDragBack => isCurrent && !isFirst && popDisposition != RoutePopDisposition.doNotPop;

  void _onDragStart() {
    if (!_canDragBack || controller == null || navigator == null) return;
    _dragController = controller;
    _dragNavigator = navigator;
    _dragNavigator!.didStartUserGesture();
  }

  /// [delta] 为横向位移（像素），向右为正；[width] 为页面宽度
  void _onDragUpdate(double delta, double width) {
    final c = _dragController;
    if (c == null || width <= 0) return;
    c.value -= delta / width;
  }

  /// [velocity] 为横向速度（像素/秒），向右为正
  void _onDragEnd(double velocity, double width) {
    final c = _dragController;
    final nav = _dragNavigator;
    _dragController = null;
    _dragNavigator = null;
    if (c == null || nav == null || width <= 0) return;

    const curve = Curves.fastEaseInToSlowEaseOut;
    final v = velocity / width;
    final bool animateForward;
    if (!isCurrent) {
      animateForward = isActive;
    } else if (v.abs() >= _minFlingVelocity) {
      animateForward = v <= 0;
    } else {
      animateForward = c.value > 0.5;
    }

    if (animateForward) {
      c.animateTo(1.0, duration: _dropDuration, curve: curve);
    } else {
      if (isCurrent) nav.pop();
      if (c.isAnimating) {
        c.animateBack(0.0, duration: _dropDuration, curve: curve);
      }
    }

    if (c.isAnimating) {
      // 动画结束前保持 userGesture 状态，避免过渡曲线中途变化
      late AnimationStatusListener listener;
      listener = (status) {
        nav.didStopUserGesture();
        c.removeStatusListener(listener);
      };
      c.addStatusListener(listener);
    } else {
      nav.didStopUserGesture();
    }
  }
}

/// 捕获全屏横向拖拽并转交给路由。内部横向滚动组件会先参与手势竞争，因此不会被抢走。
class _SwipeBackGesture extends StatelessWidget {
  const _SwipeBackGesture({required this.onStart, required this.onUpdate, required this.onEnd, required this.child});

  final VoidCallback onStart;
  final void Function(double delta, double width) onUpdate;
  final void Function(double velocity, double width) onEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => onStart(),
      onHorizontalDragUpdate: (details) => onUpdate(details.primaryDelta ?? 0, context.size?.width ?? 0),
      onHorizontalDragEnd: (details) => onEnd(details.primaryVelocity ?? 0, context.size?.width ?? 0),
      onHorizontalDragCancel: () => onEnd(0, context.size?.width ?? 0),
      child: child,
    );
  }
}
