/// 首页轮播图数据模型
///
/// 接口：POST /api/common/v3/getcarousellist
/// 响应字段：title, imgurl, jumptype, viewurl, postdata
library;

// ─── CarouselType ────────────────────────────────────────────────────────────

/// 轮播图类型，对应后端 CarouselType 枚举。
enum CarouselType {
  /// 小程序首页
  appHome(1),
  /// 定制酒商城首页
  templateHome(2),
  /// 老酒商城
  jarShop(3),
  /// 旅游商城
  travelShop(4),
  /// 常规商品商城
  ordinaryShop(5),
  /// 互动游戏
  game(6),
  /// 封坛酒首页
  storedWin(7),
  ;

  const CarouselType(this.value);
  final int value;

  factory CarouselType.fromJson(dynamic json) {
    final int? v = json is int ? json : (json as num?)?.toInt();
    return _byValue[v] ?? appHome;
  }

  static final Map<int, CarouselType> _byValue = {
    for (final e in CarouselType.values) e.value: e,
  };
}

// ─── JumpType ────────────────────────────────────────────────────────────────

/// 轮播图点击跳转方式，对应后端 JumpType 枚举。
enum JumpType {
  none(0),            // 不可跳转
  webView(1),         // WebView 界面
  productList(2),     // 商品列表
  productDetail(3),   // 商品详情
  customizeOrder(4),  // 定制酒
  couponList(5),      // 优惠券列表
  creditMall(6),      // 积分商城
  couponCentre(7),    // 领券中心
  vipList(8),         // 会员卡列表
  serviceList(9),     // 服务券列表
  cart(10),           // 购物车
  orderList(11),      // 订单列表
  customerService(12),// 专属客服
  otherPlatformList(13), // 异业卡列表
  programPage(14),    // 小程序 or App 内部页面
  zjProgramPage(15),  // 中酒小程序页面
  minProgram(16),     // 第三方小程序
  ;

  const JumpType(this.value);
  final int value;

  factory JumpType.fromJson(dynamic json) {
    final int? v = json is int ? json : (json as num?)?.toInt();
    return _byValue[v] ?? none;
  }

  static final Map<int, JumpType> _byValue = {
    for (final e in JumpType.values) e.value: e,
  };
}

// ─── CarouselBanner ──────────────────────────────────────────────────────────

/// 单个轮播图数据项，对应后端 CarouselModel。
class CarouselBanner {
  final String title;
  final String imageUrl;
  final JumpType jumpType;
  final String viewUrl; // 跳转链接（对应 viewurl）
  final String postData; // 跳转附加数据（对应 postdata）

  const CarouselBanner({
    required this.title,
    required this.imageUrl,
    required this.jumpType,
    required this.viewUrl,
    required this.postData,
  });

  factory CarouselBanner.fromJson(Map<String, dynamic> json) {
    return CarouselBanner(
      title: json['title'] as String? ?? '',
      imageUrl: (json['imgurl'] as String? ?? '').replaceAll('&amp;', '&'),
      jumpType: JumpType.fromJson(json['jumptype']),
      viewUrl: json['viewurl'] as String? ?? '',
      postData: json['postdata'] as String? ?? '',
    );
  }
}

/// 轮播图列表响应数据（从 carousellist 字段解析）
class CarouselListData {
  final List<CarouselBanner> banners;
  final String dataTag;

  const CarouselListData({required this.banners, required this.dataTag});

  factory CarouselListData.fromJson(Map<String, dynamic> json) {
    final list = json['carousellist'] as List<dynamic>? ?? [];
    return CarouselListData(
      banners: list.map((e) => CarouselBanner.fromJson(e as Map<String, dynamic>)).toList(),
      dataTag: json['datatag'] as String? ?? '',
    );
  }
}
