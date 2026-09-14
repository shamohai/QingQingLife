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

  // TODO: 10张图标替换后直接生效，无需改代码
  static const _tabAssets = [
    (selected: 'assets/icon/tab_home_selected.png',  unselected: 'assets/icon/tab_home_unselected.png'),
    (selected: 'assets/icon/tab_points_selected.png',  unselected: 'assets/icon/tab_points_unselected.png'),
    (selected: 'assets/icon/tab_shop_selected.png',    unselected: 'assets/icon/tab_shop_unselected.png'),
    (selected: 'assets/icon/tab_service_selected.png', unselected: 'assets/icon/tab_service_unselected.png'),
    (selected: 'assets/icon/tab_profile_selected.png', unselected: 'assets/icon/tab_profile_unselected.png'),
  ];

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
            children: List.generate(5, (i) => Expanded(
              child: _TabItem(
                index: i,
                selectedAsset: _tabAssets[i].selected,
                unselectedAsset: _tabAssets[i].unselected,
                label: ['首页', '积分商城', '特色商城', '服务中心', '我的'][i],
                isSelected: i == idx,
                onTap: () => _goBranch(i),
              ),
            )),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final int index;
  final String selectedAsset;
  final String unselectedAsset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.index,
    required this.selectedAsset,
    required this.unselectedAsset,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isSelected ? selectedAsset : unselectedAsset,
            width: 26,
            height: 26,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
