import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/shop/presentation/pages/shop_page.dart';
import '../../features/points_mall/presentation/pages/points_mall_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/member/presentation/pages/profile_page.dart';
import '../../features/service/presentation/pages/service_page.dart';
import '../../features/service/presentation/pages/service_cart_page.dart';
import '../../features/service/presentation/pages/service_records_page.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/phone_bind_page.dart';
import 'route_names.dart';

final appRouter = Provider<GoRouter>((ref) {
  const devRoute = String.fromEnvironment('QINGQING_DEV_ROUTE');
  return GoRouter(
    initialLocation: devRoute.isNotEmpty ? devRoute : RouteNames.home,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(path: RouteNames.login, pageBuilder: (c, s) => const MaterialPage(child: LoginPage())),
      GoRoute(path: RouteNames.phoneBind, pageBuilder: (c, s) => const MaterialPage(child: PhoneBindPage())),
      StatefulShellRoute.indexedStack(
        builder: (c, s, ns) => MainShell(navigationShell: ns),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.home, pageBuilder: (c, s) => const NoTransitionPage(child: HomePage()), routes: [
              GoRoute(path: 'product/:id', pageBuilder: (c, s) => MaterialPage(child: ProductDetailPage(productId: s.pathParameters['id']!))),
            ]),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: RouteNames.points, pageBuilder: (c, s) => const NoTransitionPage(child: PointsMallPage()))]),
          StatefulShellBranch(routes: [GoRoute(path: RouteNames.shop, pageBuilder: (c, s) => const NoTransitionPage(child: ShopPage()))]),
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.service, pageBuilder: (c, s) => const NoTransitionPage(child: ServicePage()), routes: [
              GoRoute(path: 'records', pageBuilder: (c, s) => MaterialPage(child: ServiceRecordsPage(activeTab: s.uri.queryParameters['activeTab'] ?? 'ongoing'))),
            ]),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: RouteNames.profile, pageBuilder: (c, s) => const NoTransitionPage(child: ProfilePage()))]),
        ],
      ),
      GoRoute(path: RouteNames.cart, pageBuilder: (c, s) => const MaterialPage(child: CartPage())),
      GoRoute(path: RouteNames.checkout, pageBuilder: (c, s) => const MaterialPage(child: CartPage())),
      GoRoute(path: RouteNames.serviceCart, pageBuilder: (c, s) => const MaterialPage(child: ServiceCartPage())),
    ],
  );
});

/// 底部 Tab 主框架
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  void _goBranch(int index) => navigationShell.goBranch(index, initialLocation: true);

  @override
  Widget build(BuildContext context) {
    final idx = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTab(0, 'assets/images/points/icon-home.png', '首页', idx),
              _buildTab(1, 'assets/images/points/icon-points-selected.png', '积分商城', idx),
              _buildTab(2, 'assets/images/points/icon-shop.png', '特色商城', idx),
              _buildTab(3, 'assets/images/points/icon-service.png', '服务中心', idx),
              _buildTab(4, 'assets/images/points/icon-profile.png', '我的', idx),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String asset, String label, int currentIdx) {
    final bool selected = index == currentIdx;
    return GestureDetector(
      onTap: () => _goBranch(index),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              asset,
              width: 26,
              height: 26,
              color: selected ? const Color(0xFF0088FF) : const Color(0xFF8E8E93),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? const Color(0xFF0088FF) : const Color(0xFF8E8E93),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
