import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// 4 个主 Tab 的 PageView 容器：跟手拖动，相邻 Tab 边拖边露出，松手后吸附。
///
/// 通过 StatefulShellRoute.navigatorContainerBuilder 接入，每个 child 是一个分支的 Navigator，
/// 因此各 Tab 的导航栈、滚动位置和页面状态保持不变。
/// 当分支内存在被推入的二级页面（如明细页）时锁定滑动，由二级页面自身的右滑返回处理。
class MainTabPageView extends StatefulWidget {
  const MainTabPageView({super.key, required this.navigationShell, required this.children});

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  State<MainTabPageView> createState() => _MainTabPageViewState();
}

class _MainTabPageViewState extends State<MainTabPageView> {
  late final PageController _controller = PageController(initialPage: widget.navigationShell.currentIndex);
  GoRouter? _router;
  bool _locked = false;

  /// 程序触发的翻页动画进行中。动画途经的中间页不应被当作用户滑动，否则会切到错误的分支。
  bool _programmaticScroll = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (!identical(router, _router)) {
      _router?.routerDelegate.removeListener(_onRouteChanged);
      _router = router;
      router.routerDelegate.addListener(_onRouteChanged);
      _locked = router.canPop();
    }
  }

  void _onRouteChanged() {
    final locked = _router?.canPop() ?? false;
    if (locked != _locked && mounted) setState(() => _locked = locked);
  }

  @override
  void didUpdateWidget(covariant MainTabPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final idx = widget.navigationShell.currentIndex;
    if (idx != oldWidget.navigationShell.currentIndex && _controller.hasClients && _controller.page?.round() != idx) {
      _programmaticScroll = true;
      _controller.animateToPage(idx, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic).whenComplete(() {
        if (mounted) _programmaticScroll = false;
      });
    }
  }

  void _onPageChanged(int index) {
    if (_programmaticScroll) return;
    if (index != widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(index, initialLocation: true);
    }
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRouteChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      physics: _locked ? const NeverScrollableScrollPhysics() : null,
      onPageChanged: _onPageChanged,
      children: [for (final child in widget.children) _KeepAlivePage(child: child)],
    );
  }
}

/// 保持 Tab 页面存活，切换时不销毁分支 Navigator 与页面状态。
class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});

  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
