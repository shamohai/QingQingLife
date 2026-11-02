import 'package:go_router/go_router.dart';

import 'route_names.dart';

/// 构造登录页地址，并通过 `from` 保存登录后要返回的应用内路由。
///
/// 用法：在公开页面的受限操作入口调用：
/// ```dart
/// context.push(loginLocationFor(GoRouterState.of(context).uri.toString()));
/// ```
/// 登录成功后使用 [safeReturnTo] 校验 `from`，再恢复原有路由栈。
String loginLocationFor(String returnTo) {
  return Uri(path: RouteNames.login, queryParameters: {'from': returnTo}).toString();
}

/// 选择登录完成后的路由恢复策略。
///
/// 当登录页是从公开页面 push 进入时，登录页及可能的手机号绑定页都位于
/// 原页面之上，因此应 pop 回原栈，避免 go 重建目标页并丢失它的前置页面。
enum LoginReturnStrategy { pop, navigate }

LoginReturnStrategy loginReturnStrategy({required bool hasValidReturnTo, required bool canPop}) {
  return hasValidReturnTo || canPop ? LoginReturnStrategy.pop : LoginReturnStrategy.navigate;
}

/// 校验登录后的回跳地址，只允许应用内的绝对路径。
///
/// 外部 URL、协议相对地址、空值以及登录/绑定手机号页面都会被拒绝，
/// 避免开放重定向和登录页之间循环跳转。失败时调用方应使用默认页面。
/// 页面登录成功时读取 `GoRouterState.of(context).uri.queryParameters['from']`，
/// 传入本方法校验；对于 push 登录应优先 pop 恢复原导航栈。
String? safeReturnTo(String? candidate) {
  if (candidate == null || candidate.isEmpty) return null;

  final uri = Uri.tryParse(candidate);
  if (uri == null || uri.hasScheme || uri.hasAuthority || !uri.path.startsWith('/') || uri.path.startsWith('//')) {
    return null;
  }
  if (uri.path == RouteNames.login || uri.path == RouteNames.phoneBind) return null;

  return uri.toString();
}

/// 根据当前 GoRouter 路由状态判断整页是否需要登录。
///
/// 由 [appRouter] 的全局 redirect 调用；页面通常不需要直接调用它。
/// 公开详情页若只有某个操作要求登录，不要把详情页路径加入下面的受保护列表，
/// 应在操作回调里单独引导登录并保存当前路由，例如积分商品详情的“立即兑换”。
bool requiresAuthentication(GoRouterState state) => isProtectedPath(state.uri.path);

/// 判断路径是否命中需要登录的路由模板。
///
/// 使用方法：新增需要登录的页面时，先在 `app_router.dart` 注册路由，
/// 再把路由模板加入 `protectedPatterns`。例如静态路径加入 `/aaaa/bbbb`；
/// 动态路径加入 `/aaaa/:id`。匹配按路径段进行，`:id` 仅匹配对应的一段；
/// 查询参数不影响匹配。不要只按 `/member` 等前缀拦截，以免保护同组公开页面。
///
/// 示例：
/// ```dart
/// // 页面本身必须登录：在 protectedPatterns 中添加 '/account/private'。
/// // 页面可公开，但操作要求登录：不添加页面路径，在操作中调用：
/// context.push(loginLocationFor(GoRouterState.of(context).uri.toString()));
/// ```
bool isProtectedPath(String path) {
  final pathSegments = Uri(path: path).pathSegments;

  // 页面级登录白名单（准确说是“需要登录的路由模板”）：
  // - 静态路由直接填写完整路径，如 `/aaaa/bbbb`。
  // - 动态路由用 `:参数名` 表示单个路径段，如 `/aaaa/:id`。
  // - 查询参数不写在这里，例如 `/orders?status=paid` 只匹配 `/orders`。
  // - 仅对整页都不适合访客访问的页面配置；公开页面里的登录操作应在操作处鉴权。
  // 新增路由后，通常只需在此集合添加对应路径模板，无需在页面里重复写整页拦截。
  const protectedPatterns = <String>{
    RouteNames.memberSignIn,
    RouteNames.personalInfo,
    '${RouteNames.personalInfo}/edit',
    '${RouteNames.personalInfo}/account-deletion',
    RouteNames.serviceRecords,
    RouteNames.pointsDetail,
    RouteNames.serviceCart,
    RouteNames.serviceBookingForm,
    RouteNames.notifications,
    '/points/service/:id/confirm',
    '/points/service/:id/coupon-order',
    RouteNames.orders,
    '${RouteNames.orders}/:id',
    '${RouteNames.orders}/invoices',
    '${RouteNames.orders}/invoices/detail/:id',
    RouteNames.address,
    '${RouteNames.address}/add',
    '${RouteNames.address}/edit',
    RouteNames.coupons,
    '${RouteNames.coupons}/list',
    '${RouteNames.coupons}/red-packet',
    '${RouteNames.coupons}/service',
    '${RouteNames.coupons}/service/use',
  };

  return protectedPatterns.any((pattern) {
    final patternSegments = Uri(path: pattern).pathSegments;
    if (patternSegments.length != pathSegments.length) return false;
    for (var i = 0; i < patternSegments.length; i++) {
      if (patternSegments[i].startsWith(':')) continue;
      if (patternSegments[i] != pathSegments[i]) return false;
    }
    return true;
  });
}
