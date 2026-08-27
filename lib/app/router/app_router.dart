import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/shop/presentation/pages/shop_page.dart';
import '../../features/points_mall/presentation/pages/points_mall_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/member/presentation/pages/profile_page.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import 'route_names.dart';

/// 主应用路由器，使用 StatefulShellRoute 保持各 Tab 独立导航栈
final appRouter = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.home,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomePage()),
                routes: [
                  GoRoute(
                    path: 'product/:id',
                    pageBuilder: (context, state) => MaterialPage(
                      child: ProductDetailPage(
                        productId: state.pathParameters['id']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.points,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PointsMallPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.shop,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ShopPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.cart,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CartPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfilePage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// 底部 Tab 主框架（顺序：首页/特色商城/积分商城/购物车/我的）
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const _tabBarItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '首页'),
    BottomNavigationBarItem(
      icon: Icon(Icons.point_of_sale_outlined),
      label: '积分商城',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.storefront_outlined),
      label: '特色商城',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart_outlined),
      label: '购物车',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '我的'),
  ];

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        items: _tabBarItems,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
