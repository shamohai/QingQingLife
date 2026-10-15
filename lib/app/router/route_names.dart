/// 所有路由名称常量，避免魔法字符串
abstract final class RouteNames {
  // 主 Tab 路由
  static const String home = '/home';
  static const String shop = '/shop';
  static const String service = '/service';
  static const String points = '/points';
  static const String profile = '/profile';

  // 商品相关
  static const String productDetail = '/product/:id';

  // 购物车与结算
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String paymentResult = '/payment-result';
  static const String serviceCart = '/service/cart';

  // 订单相关
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  // 发票中心
  static const String invoiceCenter = '/orders/invoices';
  // 发票申请记录详情
  static const String invoiceDetail = '/orders/invoices/detail/:id';

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
  // 积分商城服务商品详情
  static const String serviceProductDetail = '/points/service/:id';

  // 积分商城服务商品确认订单
  static const String confirmOrder = '/points/service/:id/confirm';

  // 消息通知
  static const String notifications = '/notifications';

  // 客服
  static const String customerService = '/customer-service';

  // 预约项目详情
  static const String serviceProjectDetail = '/service/project/:id';

  // 预约项目填写信息
  static const String serviceActivityBookingForm = '/service/activity/:id/book';
  // 预约项目填写信息
  static const String serviceBookingForm = '/service/project/:id/book';

  // 购酒享服务模板详情
  static const String serviceTemplateDetail = '/service/template/:id';

  // 积分规则页
  static const String pointsRules = '/points/rules';

  // 全部商品
  static const String allProducts = '/points/all-products';
}
