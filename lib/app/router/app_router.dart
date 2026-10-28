import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/shop/presentation/pages/shop_page.dart';
import '../../features/points_mall/presentation/pages/points_mall_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/member/presentation/pages/profile_page.dart';
import '../../features/member/presentation/pages/member_level_page.dart';
import '../../features/member/presentation/pages/member_sign_in_page.dart';
import '../../features/member/presentation/pages/personal_info_page.dart';
import '../../features/member/presentation/pages/personal_info_edit_page.dart';
import '../../features/member/presentation/pages/about_us_page.dart';
import '../../features/member/presentation/pages/account_deletion_page.dart';
import '../../features/member/presentation/pages/address_list_page.dart';
import '../../features/member/presentation/pages/address_form_page.dart';
import '../../features/member/presentation/pages/my_coupons_page.dart';
import '../../features/member/presentation/pages/coupon_list_page.dart';
import '../../features/member/presentation/pages/locked_red_packet_list_page.dart';
import '../../features/member/presentation/pages/service_coupon_list_page.dart';
import '../../features/member/presentation/pages/service_coupon_use_page.dart';
import '../../features/member/data/models/service_coupon_model.dart';
import '../../features/member/domain/repositories/member_repository.dart';
import '../../features/notification/presentation/pages/notification_list_page.dart';
import '../../features/service/presentation/pages/service_page.dart';
import '../../features/service/presentation/pages/service_cart_page.dart';
import '../../features/service/presentation/pages/service_records_page.dart';
import '../../features/service/presentation/pages/service_project_detail_page.dart';
import '../../features/service/presentation/pages/service_booking_form_page.dart';
import '../../features/service/presentation/pages/service_template_detail_page.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/phone_bind_page.dart';
import '../../features/login/presentation/pages/token_debug_page.dart';
import '../../features/points_mall/presentation/pages/service_product_detail_page.dart';
import '../../features/points_mall/presentation/pages/confirm_order_page.dart';
import '../../features/points_mall/presentation/pages/all_products_page.dart';
import '../../features/points_mall/presentation/pages/points_payment_success_page.dart';
import '../../core/presentation/pages/webview_page.dart';
import '../../features/order/presentation/pages/service_coupon_confirm_order_page.dart';
import '../../features/points/presentation/pages/points_detail_page.dart';
import '../../features/points/presentation/pages/points_rules_page.dart';
import '../../features/order/presentation/pages/all_orders_page.dart';
import '../../features/order/presentation/pages/confirm_order_page.dart' as mall_order;
import '../../features/order/presentation/pages/invoice_center_page.dart';
import '../../features/order/presentation/pages/invoice_detail_page.dart';
import '../../features/order/presentation/pages/mall_payment_success_page.dart';
import '../../features/order/presentation/pages/order_detail_page.dart';
import 'route_names.dart';

final appRouter = Provider<GoRouter>((ref) {
  const devRoute = String.fromEnvironment('QINGQING_DEV_ROUTE');
  return GoRouter(
    initialLocation: devRoute.isNotEmpty ? devRoute : RouteNames.home,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (c, s) => const MaterialPage(child: LoginPage()),
      ),
      GoRoute(
        path: RouteNames.tokenDebug,
        pageBuilder: (c, s) => const MaterialPage(child: TokenDebugPage()),
      ),
      GoRoute(
        path: RouteNames.phoneBind,
        pageBuilder: (c, s) => const MaterialPage(child: PhoneBindPage()),
      ),
      GoRoute(
        path: RouteNames.productDetail,
        pageBuilder: (c, s) => MaterialPage(child: ProductDetailPage(productId: s.pathParameters['id']!)),
      ),
      StatefulShellRoute.indexedStack(
        builder: (c, s, ns) => MainShell(navigationShell: ns),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                pageBuilder: (c, s) => const NoTransitionPage(child: HomePage()),
                routes: [
                  GoRoute(
                    path: 'product/:id',
                    pageBuilder: (c, s) => MaterialPage(child: ProductDetailPage(productId: s.pathParameters['id']!)),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.points,
                pageBuilder: (c, s) => const NoTransitionPage(child: PointsMallPage()),
              ),
            ],
          ),
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: RouteNames.shop,
          //       pageBuilder: (c, s) => const NoTransitionPage(child: ShopPage()),
          //     ),
          //   ],
          // ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.service,
                pageBuilder: (c, s) => const NoTransitionPage(child: ServicePage()),
                routes: [
                  GoRoute(
                    path: 'records',
                    pageBuilder: (c, s) => MaterialPage(child: ServiceRecordsPage(activeTab: s.uri.queryParameters['activeTab'] ?? 'ongoing')),
                  ),
                  GoRoute(
                    path: 'project/:id',
                    pageBuilder: (c, s) => MaterialPage(child: ServiceProjectDetailPage(projectId: s.pathParameters['id']!)),
                  ),
                  GoRoute(
                    name: 'serviceBookingForm',
                    path: RouteNames.serviceBookingForm,
                    pageBuilder: (c, s) => MaterialPage(
                      child: ServiceBookingFormPage(projectId: s.pathParameters['id']!, title: s.uri.queryParameters['title'] ?? '预约项目'),
                    ),
                  ),
                  GoRoute(
                    path: 'template/:id',
                    pageBuilder: (c, s) => MaterialPage(child: ServiceTemplateDetailPage(templateId: int.tryParse(s.pathParameters['id']!) ?? 0)),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                pageBuilder: (c, s) => const NoTransitionPage(child: ProfilePage()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.memberLevel,
        pageBuilder: (c, s) => MaterialPage(child: const MemberLevelPage()),
      ),
      GoRoute(
        path: RouteNames.memberSignIn,
        pageBuilder: (c, s) => const MaterialPage(child: MemberSignInPage()),
      ),
      GoRoute(
        path: RouteNames.personalInfo,
        pageBuilder: (c, s) => const MaterialPage(child: PersonalInfoPage()),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (c, s) => const MaterialPage(child: PersonalInfoEditPage()),
          ),
          GoRoute(
            path: 'account-deletion',
            pageBuilder: (c, s) => const MaterialPage(child: AccountDeletionPage()),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.aboutUs,
        pageBuilder: (c, s) => const MaterialPage(child: AboutUsPage()),
      ),
      GoRoute(
        path: RouteNames.coupons,
        pageBuilder: (c, s) => const MaterialPage(child: MyCouponsPage()),
      ),
      GoRoute(
        path: RouteNames.couponList,
        pageBuilder: (c, s) => const MaterialPage(child: CouponListPage()),
      ),
      GoRoute(
        path: RouteNames.lockedRedPacketList,
        pageBuilder: (c, s) => const MaterialPage(child: LockedRedPacketListPage()),
      ),
      GoRoute(
        path: RouteNames.serviceCouponList,
        pageBuilder: (c, s) => const MaterialPage(child: ServiceCouponListPage()),
      ),
      GoRoute(
        path: RouteNames.serviceCouponUse,
        pageBuilder: (c, s) => MaterialPage(child: ServiceCouponUsePage(coupon: s.extra as ServiceCouponInfo)),
      ),
      GoRoute(
        path: RouteNames.address,
        pageBuilder: (c, s) => const MaterialPage(child: AddressListPage()),
      ),
      GoRoute(
        path: RouteNames.addressAdd,
        pageBuilder: (c, s) => const MaterialPage(child: AddressFormPage()),
      ),
      GoRoute(
        path: RouteNames.addressEdit,
        pageBuilder: (c, s) => MaterialPage(child: AddressFormPage(initial: s.extra is MemberAddress ? s.extra as MemberAddress : null)),
      ),
      GoRoute(
        path: RouteNames.notifications,
        pageBuilder: (c, s) => const MaterialPage(child: NotificationListPage()),
      ),
      GoRoute(
        path: RouteNames.serviceProductDetail,
        pageBuilder: (c, s) => MaterialPage(child: ServiceProductDetailPage(productId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: RouteNames.confirmOrder,
        pageBuilder: (c, s) {
          final userServiceIdStr = s.uri.queryParameters['userServiceId'];
          final userServiceId = userServiceIdStr != null ? int.tryParse(userServiceIdStr) : null;
          return MaterialPage(
            child: ConfirmOrderPage(productId: s.pathParameters['id']!, userServiceId: userServiceId),
          );
        },
      ),
      GoRoute(
        path: RouteNames.serviceCouponConfirmOrder,
        pageBuilder: (c, s) {
          final serviceCouponId = int.tryParse(s.pathParameters['id'] ?? '') ?? 0;
          final initialCount = int.tryParse(s.uri.queryParameters['count'] ?? '') ?? 1;
          return MaterialPage(
            child: ServiceCouponConfirmOrderPage(serviceCouponId: serviceCouponId, initialCount: initialCount),
          );
        },
      ),
      GoRoute(
        path: RouteNames.allProducts,
        pageBuilder: (c, s) => const MaterialPage(child: AllProductsPage()),
      ),
      if (!kIsWeb)
        GoRoute(
          path: RouteNames.webView,
          pageBuilder: (c, s) {
            final url = s.uri.queryParameters['url'] ?? '';
            final uri = Uri.tryParse(url);
            if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
              return const MaterialPage(child: Scaffold(body: Center(child: Text('无效的网页地址'))));
            }
            return MaterialPage(child: WebViewPage(url: url));
          },
        ),
      GoRoute(
        path: RouteNames.paymentResult,
        pageBuilder: (c, s) => MaterialPage(child: PointsPaymentSuccessPage.fromExtra(s.extra)),
      ),
      GoRoute(
        path: RouteNames.cart,
        pageBuilder: (c, s) => const MaterialPage(child: CartPage()),
      ),
      GoRoute(
        path: RouteNames.checkout,
        pageBuilder: (c, s) => const MaterialPage(child: CartPage()),
      ),
      GoRoute(
        path: RouteNames.mallConfirmOrder,
        pageBuilder: (c, s) => const MaterialPage(child: mall_order.ConfirmOrderPage()),
      ),
      GoRoute(
        path: RouteNames.mallPaymentSuccess,
        pageBuilder: (c, s) => MaterialPage(child: MallPaymentSuccessPage.fromExtra(s.extra)),
      ),
      GoRoute(
        path: RouteNames.serviceCart,
        pageBuilder: (c, s) {
          final templateId = int.tryParse(s.uri.queryParameters['templateId'] ?? '') ?? 0;
          final cartId = int.tryParse(s.uri.queryParameters['cartId'] ?? '') ?? 0;
          final headImg = s.uri.queryParameters['headImg'];
          return MaterialPage(
            child: ServiceCartPage(templateId: templateId, cartId: cartId, headImg: headImg),
          );
        },
      ),
      GoRoute(
        path: RouteNames.pointsDetail,
        pageBuilder: (c, s) => const MaterialPage(child: PointsDetailPage()),
      ),
      GoRoute(
        path: RouteNames.pointsRules,
        pageBuilder: (c, s) => const MaterialPage(child: PointsRulesPage()),
      ),
      GoRoute(
        path: RouteNames.orders,
        pageBuilder: (c, s) => MaterialPage(child: AllOrdersPage(initialStatus: s.uri.queryParameters['status'])),
      ),
      GoRoute(
        path: RouteNames.invoiceCenter,
        pageBuilder: (c, s) => const MaterialPage(child: InvoiceCenterPage()),
        routes: [
          GoRoute(
            path: 'detail/:id',
            pageBuilder: (c, s) => MaterialPage(child: InvoiceDetailPage(invoiceId: s.pathParameters['id']!)),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.orderDetail,
        pageBuilder: (c, s) => MaterialPage(child: OrderDetailPage(orderId: s.pathParameters['id']!)),
      ),
    ],
  );
});

/// 底部 Tab 主框架
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});
  void _goBranch(int index) => navigationShell.goBranch(index, initialLocation: true);
  static const _tabAssets = [
    (selected: 'assets/icon/tab_home_selected.png', unselected: 'assets/icon/tab_home_unselected.png'),
    (selected: 'assets/icon/tab_points_selected.png', unselected: 'assets/icon/tab_points_unselected.png'),
    // (selected: 'assets/icon/tab_shop_selected.png', unselected: 'assets/icon/tab_shop_unselected.png'),
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
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (i) => Expanded(
                  child: _TabItem(
                    index: i,
                    selectedAsset: _tabAssets[i].selected,
                    unselectedAsset: _tabAssets[i].unselected,
                    label: ['首页', '积分商城', '服务中心', '我的'][i],
                    isSelected: i == idx,
                    onTap: () => _goBranch(i),
                  ),
                ),
              ),
            ),
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
          Image.asset(isSelected ? selectedAsset : unselectedAsset, width: 26, height: 26),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: isSelected ? const Color(0xFF213775) : const Color(0xFF656565)),
          ),
        ],
      ),
    );
  }
}
