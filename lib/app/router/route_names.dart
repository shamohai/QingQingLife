/// 所有路由名称常量，避免魔法字符串
abstract final class RouteNames {
  // 主 Tab 路由
  static const String home = '/home';
  static const String service = '/service';
  static const String points = '/points';
  static const String profile = '/profile';

  // 商品相关
  static const String productDetail = '/product/:id';
  static const String homeProductDetail = '/home/product/:id';

  // 购物车与结算
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String paymentResult = '/payment-result';
  static const String serviceCart = '/service/cart';

  // 订单相关
  static const String orders = '/orders';
  static const String mallConfirmOrder = '/orders/confirm';
  static const String mallPaymentSuccess = '/orders/payment-success';
  static const String orderDetail = '/orders/:id';
  // 发票中心
  static const String invoiceCenter = '/orders/invoices';
  // 发票申请记录详情
  static const String invoiceDetail = '/orders/invoices/detail/:id';

  // 积分功能路由位于统一 points feature 下；URL 对外保持不变。
  // 会员相关
  static const String memberLevel = '/member/level';
  static const String memberSignIn = '/member/sign-in';
  static const String personalInfo = '/member/personal-info';
  // 个人信息编辑页（旧版表单，由账号安全页底部「修改个人信息」进入）
  static const String personalInfoEdit = '/member/personal-info/edit';
  // 注销协议页（由账号安全页底部「注销账号」进入，personalInfo 子路由）
  static const String accountDeletion = '/member/personal-info/account-deletion';
  static const String aboutUs = '/member/about-us';
  static const String coupons = '/coupons';
  static const String couponList = '/coupons/list';
  static const String lockedRedPacketList = '/coupons/red-packet';
  static const String cashCouponShareReceive = '/coupons/cash/receive';
  static const String serviceCouponList = '/coupons/service';
  static const String serviceCouponUse = '/coupons/service/use';
  static const String serviceCouponReceive = '/coupons/service/receive';

  /// App 内统一链接分发入口：读取 `route` 与其余参数后跳转到目标页面。
  static const String appLinkDispatch = '/link/dispatch';
  static const String pointsPage = '/points';
  static const String pointsMall = '/points/mall';

  // 地址相关
  // 积分明细页
  static const String pointsDetail = '/points/detail';
  static const String address = '/address';
  static const String addressAdd = '/address/add';
  static const String addressEdit = '/address/edit';

  // 登录
  static const String login = '/login';
  static const String phoneBind = '/phone-bind';

  // 服务预约子路由
  static const String serviceRecords = '/service/records';
  static const String serviceBookingSuccess = '/service/booking-success';
  static const String serviceBookingRecordDetail = '/service/booking-record-detail';
  // 积分商城服务商品详情
  static const String serviceProductDetail = '/points/service/:id';

  static String serviceProductDetailPath({required String productId}) {
    return serviceProductDetail.replaceFirst(':id', Uri.encodeComponent(productId));
  }

  // 积分商城服务商品确认订单
  static const String confirmOrder = '/points/service/:id/confirm';
  // 服务券支付订单确认
  static const String serviceCouponConfirmOrder = '/points/service/:id/coupon-order';

  static String serviceCouponConfirmOrderPath({required int serviceCouponId, required int count}) {
    return Uri(path: serviceCouponConfirmOrder.replaceFirst(':id', '$serviceCouponId'), queryParameters: {'count': '$count'}).toString();
  }

  // 消息通知
  static const String notifications = '/notifications';

  // 购酒享服务付款提示（联系客服）页

  // 客服
  static const String customerService = '/customer-service';

  // 预约服务详情（服务预约 tab - 真实 API）
  static const String reservationServiceDetail = '/service/reservation/:id';

  // 挚友报名会详情（挚友会 tab）
  static const String friendDetail = '/service/friend/:id';

  // 活动详情（活动 tab）
  static const String activityDetail = '/service/activity/:id';

  // 活动报名填写信息
  static const String serviceActivityBookingForm = '/service/activity/:id/book';
  // 预约项目填写信息
  static const String serviceBookingForm = '/service/project/:id/book';

  // 挚友报名填写信息
  static const String serviceFriendBookingForm = '/service/friend/:id/book';

  // 购酒享服务模板详情
  static const String serviceTemplateDetail = '/service/template/:id/:userServiceId';

  // 我的权益 - 权益商城模板详情（顶层入口，避免从 shell 外 push 分支内路由）
  static const String memberServiceTemplateDetail = '/member/service-template/:id';

  static String serviceTemplateDetailPath({required int templateId, int? userServiceId}) {
    return _serviceTemplateDetailPath(serviceTemplateDetail, templateId: templateId, userServiceId: userServiceId);
  }

  static String memberServiceTemplateDetailPath({required int templateId, int? userServiceId}) {
    return _serviceTemplateDetailPath(memberServiceTemplateDetail, templateId: templateId, userServiceId: userServiceId);
  }

  static String _serviceTemplateDetailPath(String path, {required int templateId, int? userServiceId}) {
    return Uri(
      path: path.replaceFirst(':id', '$templateId'),
      queryParameters: userServiceId != null && userServiceId > 0 ? {'userServiceId': '$userServiceId'} : null,
    ).toString();
  }

  // 积分规则页
  static const String pointsRules = '/points/rules';
  static const String pointsRulesUrl = 'https://wx.mall.qkj.com.cn/mob/Account/CreditRule?from=app';

  // 全部商品（categoryid 通过 query 参数传递，默认 0）
  static const String allProducts = '/points/all-products';

  // App 内 H5 页面：常规页面与活动页面保持独立路由和行为。
  static const String webView = '/webview';
  static const String activityWebView = '/activity/webview';
  static const String userServiceAgreementUrl = 'https://wx.mall.qkj.com.cn/mob/Account/appeula';
  static const String userPrivacyPolicyUrl = 'https://wx.mall.qkj.com.cn/mob/Account/AppPrivacyPolicy';

  /// 允许通过分享 Schema 打开的页面。
  ///
  /// 只收录可以仅凭路径和 query 参数恢复的页面；依赖 `extra` 对象的路由
  /// 不能加入，否则外部链接直达时会缺少页面数据。
  static const Set<String> deepLinkRoutes = {
    home,
    points,
    service,
    profile,
    productDetail,
    homeProductDetail,
    serviceProductDetail,
    reservationServiceDetail,
    friendDetail,
    activityDetail,
    serviceTemplateDetail,
    memberServiceTemplateDetail,
    pointsDetail,
    allProducts,
    orders,
    orderDetail,
    memberLevel,
    coupons,
    couponList,
    cashCouponShareReceive,
    serviceCouponList,
    serviceCouponReceive,
    appLinkDispatch,
    notifications,
    customerService,
    cart,
    serviceCart,
    address,
    addressAdd,
    addressEdit,
    aboutUs,
    invoiceCenter,
    invoiceDetail,
    serviceRecords,
    serviceBookingRecordDetail,
  };

  /// 即使可能被动态路由模板匹配，也不允许从外部链接直达的页面。
  static const Set<String> deepLinkBlockedPaths = {mallPaymentSuccess, paymentResult, serviceBookingSuccess, serviceCouponUse};
}
