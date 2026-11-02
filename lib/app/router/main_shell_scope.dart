import 'package:flutter/widgets.dart';

/// 主 Tab 框架信息，用于页面判断底部导航是否已经占用了系统安全区。
///
/// MainShell 的底部导航在 body 之外，并且自身使用 SafeArea 处理系统导航栏；
/// Tab 页面不能再重复增加底部安全区，否则会多出一段空白。独立打开的页面
/// 没有这个 Scope 时，才由页面自己处理底部安全区。
class MainShellScope extends InheritedWidget {
  const MainShellScope({super.key, required this.hasBottomNavigation, required super.child});

  final bool hasBottomNavigation;

  static bool hasBottomNavigationOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>()?.hasBottomNavigation ?? false;
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) {
    return hasBottomNavigation != oldWidget.hasBottomNavigation;
  }
}
