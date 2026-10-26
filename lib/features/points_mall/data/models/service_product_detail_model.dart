/// 积分商城服务商品详情数据模型（API 对接后替换）
///
/// 接口：POST /api/product/getproductinfo
library;

import 'package:decimal/decimal.dart';

import 'get_recommend_product_list_model.dart';

// ── BaiLiHui 产品类型枚举 ────────────────────────────────────────────────────

enum BaiLiHuiProductType {
  selfOperatedPhysical(0), // 自营实物
  electronicCard(1), // 电子卡券
  phoneRecharge(2), // 直充话费
  ecommerce(3); // 电商

  const BaiLiHuiProductType(this.value);
  final int value;

  factory BaiLiHuiProductType.fromJson(dynamic json) {
    final int? v = json is int ? json : (json as int?)?.toInt();
    return _byValue[v] ?? BaiLiHuiProductType.selfOperatedPhysical;
  }

  static final Map<int, BaiLiHuiProductType> _byValue = {for (final e in BaiLiHuiProductType.values) e.value: e};
}

// ── 促销信息嵌套模型 ─────────────────────────────────────────────────────────

/// 促销信息（单品/赠品/店铺活动通用结构）
class PromotionInfo {
  final int promotionId;
  final String promotionTitle;
  final int activityType;
  final int promotionType;
  final String? descr;
  final double? discountValue;
  final double? discount;
  final double? disAmount;
  final List<PromotionGiftProduct> giftpIds;

  const PromotionInfo({
    required this.promotionId,
    required this.promotionTitle,
    required this.activityType,
    required this.promotionType,
    this.descr,
    this.discountValue,
    this.discount,
    this.disAmount,
    this.giftpIds = const [],
  });

  factory PromotionInfo.fromJson(Map<String, dynamic> json) {
    final giftpJson = json['giftpids'] as List<dynamic>? ?? [];
    return PromotionInfo(
      promotionId: (json['promotionid'] as int?)?.toInt() ?? 0,
      promotionTitle: json['promotiontitle'] as String? ?? '',
      activityType: (json['activitytype'] as int?)?.toInt() ?? 0,
      promotionType: (json['promotiontype'] as int?)?.toInt() ?? 0,
      descr: json['descr'] as String?,
      discountValue: (json['discountvalue'] as double?)?.toDouble(),
      discount: (json['discount'] as double?)?.toDouble(),
      disAmount: (json['disamount'] as double?)?.toDouble(),
      giftpIds: giftpJson.map((e) => PromotionGiftProduct.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

/// 促销赠品商品信息
class PromotionGiftProduct {
  final int pid;
  final String pname;
  final int num;

  const PromotionGiftProduct({required this.pid, required this.pname, required this.num});

  factory PromotionGiftProduct.fromJson(Map<String, dynamic> json) {
    return PromotionGiftProduct(pid: (json['pid'] as int?)?.toInt() ?? 0, pname: json['pname'] as String? ?? '', num: (json['num'] as int?)?.toInt() ?? 0);
  }
}

// ── 优惠券嵌套模型 ────────────────────────────────────────────────────────────

/// 商品关联优惠券
class CouponItem {
  final int storeId;
  final int couponTypeId;
  final double money;
  final double limitLowAmount;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isReceive;
  final bool allowMultTimes;
  final String? desc;

  const CouponItem({
    required this.storeId,
    required this.couponTypeId,
    required this.money,
    required this.limitLowAmount,
    this.startTime,
    this.endTime,
    required this.isReceive,
    required this.allowMultTimes,
    this.desc,
  });

  factory CouponItem.fromJson(Map<String, dynamic> json) {
    return CouponItem(
      storeId: (json['storeid'] as int?)?.toInt() ?? 0,
      couponTypeId: (json['coupontypeid'] as int?)?.toInt() ?? 0,
      money: (json['money'] as double?)?.toDouble() ?? 0.0,
      limitLowAmount: (json['limitlowamount'] as double?)?.toDouble() ?? 0.0,
      startTime: _parseDateTime(json['starttime']),
      endTime: _parseDateTime(json['endtime']),
      isReceive: json['isreceive'] == true || json['isreceive'] == 1,
      allowMultTimes: json['allowmulttimes'] == true || json['allowmulttimes'] == 1,
      desc: json['desc'] as String?,
    );
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

// ── 规格参数嵌套模型 ─────────────────────────────────────────────────────────

/// 商品规格参数（CommonPara）
class CommonPara {
  final int id;
  final String name;
  final String value;

  const CommonPara({required this.id, required this.name, required this.value});

  factory CommonPara.fromJson(Map<String, dynamic> json) {
    return CommonPara(id: (json['id'] as int?)?.toInt() ?? 0, name: json['name'] as String? ?? '', value: json['value'] as String? ?? '');
  }
}

// ── 服务券嵌套模型 ────────────────────────────────────────────────────────────

/// 产品关联的服务券配置
class ServiceCouponInfo {
  final int couponConfigId;
  final String? couponName;
  final String? descriptionHtml;
  final int surplusCount;

  const ServiceCouponInfo({required this.couponConfigId, this.couponName, this.descriptionHtml, required this.surplusCount});

  factory ServiceCouponInfo.fromJson(Map<String, dynamic> json) {
    return ServiceCouponInfo(
      couponConfigId: (json['couponconfigid'] as int?)?.toInt() ?? 0,
      couponName: json['couponname'] as String?,
      descriptionHtml: json['descriptionhtml'] as String?,
      surplusCount: (json['surpluscount'] as int?)?.toInt() ?? 0,
    );
  }
}

// ── 主模型 ───────────────────────────────────────────────────────────────────

/// 积分商城服务商品详情数据模型
///
/// 对应 API：POST /api/product/getproductinfo
///
/// UI 字段映射说明：
///   name              → title
///   prepaidprice      → points（积分显示）
///   stocknum          → remainingStock
///   monthsale         → salesCount
///   marketprice       → marketPrice
///   carouselimg[0]    → mainImageUrl / heroImageUrl
///   parameter         → specs（规格参数列表）
///   tags              → 空列表（API 无直接对应字段，保留供后续扩展）
class ServiceProductDetail {
  final String id;
  final String? heroImageUrl;
  final String title;
  final List<String> tags;
  final int points;
  final int remainingStock;
  final int salesCount;
  final Decimal marketPrice;
  final String mainImageUrl;
  final String description;
  final List<String> carouselImages;

  // ── API 原始字段（供后续扩展使用）────────────────────────────────────────

  /// 商品id（API: pid）
  final int productId;

  /// 商品单价（API: price，单位：分）
  final int priceCents;

  /// 价格+规格描述文字（API: pricedesc）
  final String? priceDesc;

  /// 是否为定制商品（API: istemplate）
  final bool isTemplate;

  /// 是否为积分商品（API: iscredit）
  final bool isCredit;

  /// 商品状态 0=正常售卖 1=下架（API: productstate）
  final int productState;

  /// 运费（API: shipfee）
  final Decimal shipFee;

  /// 商品规格（API: saleunit）
  final String? saleUnit;

  /// 最高可抵用青稞粒数（API: creditcount）
  final int creditCount;

  /// 商品类型（API: producttype）
  final CreditProductType productType;

  /// 百礼汇产品类型（API: baiLiHuiType）
  final BaiLiHuiProductType? baiLiHuiType;

  /// 福禄商品类型 0=直充 1=卡密（API: fulutype）
  final int? fuluType;

  /// 定制类型（API: templatetype）
  final int? templateType;

  /// 是否有购买权限（API: auth）
  final bool auth;

  /// 权限提示（API: authtips）
  final String? authTips;

  /// 数据版本（API: datatag）
  final String? datatag;

  /// 商品规格参数列表（API: parameter）
  final List<CommonPara> specs;

  /// 单品促销（折扣/立减/折后价）（API: singlepromotion）
  final PromotionInfo? singlePromotion;

  /// 赠品促销（API: giftpromotion）
  final List<PromotionInfo> giftpromotion;

  /// 买赠促销（API: buysendpromotion）
  final List<PromotionInfo> buysendPromotion;

  /// 店铺活动（API: storepromotion）
  final List<PromotionInfo> storePromotion;

  /// 优惠券列表（API: couponlist）
  final List<CouponItem> coupons;

  /// 产品关联的服务券配置（API: servicecoupon）
  final ServiceCouponInfo? serviceCoupon;

  const ServiceProductDetail({
    required this.id,
    this.heroImageUrl,
    required this.title,
    required this.tags,
    required this.points,
    required this.remainingStock,
    required this.salesCount,
    required this.marketPrice,
    required this.mainImageUrl,
    required this.description,
    required this.carouselImages,
    // API 原始字段
    this.productId = 0,
    this.priceCents = 0,
    this.priceDesc,
    this.isTemplate = false,
    this.isCredit = false,
    this.productState = 0,
    required this.shipFee,
    this.saleUnit,
    this.creditCount = 0,
    this.productType = CreditProductType.ordinary,
    this.baiLiHuiType,
    this.fuluType,
    this.templateType,
    this.auth = false,
    this.authTips,
    this.datatag,
    this.specs = const [],
    this.singlePromotion,
    this.giftpromotion = const [],
    this.buysendPromotion = const [],
    this.storePromotion = const [],
    this.coupons = const [],
    this.serviceCoupon,
  });

  factory ServiceProductDetail.fromJson(Map<String, dynamic> json) {
    final carouselRaw = json['carouselimg'];
    final carouselimgs = carouselRaw is List ? carouselRaw : const <dynamic>[];
    final carouselImages = carouselimgs.map((e) => e.toString()).where((u) => u.isNotEmpty).toList();
    final mainImage = carouselImages.isNotEmpty ? carouselImages.first : '';
    final heroImage = carouselImages.length > 1 ? carouselImages[1] : mainImage;

    final serviceCouponMap = json['servicecoupon'] is Map ? Map<String, dynamic>.from(json['servicecoupon'] as Map) : null;
    final serviceCoupon = serviceCouponMap != null ? ServiceCouponInfo.fromJson(serviceCouponMap) : null;

    return ServiceProductDetail(
      id: json['pid'] != null && json['pid'].toString().isNotEmpty ? json['pid'].toString() : 'service_001',
      heroImageUrl: heroImage.isEmpty ? null : heroImage,
      title: json['name'] as String? ?? '',
      tags: const [],
      points: (json['price'] as int?)?.toInt() ?? 0, // 积分
      remainingStock: serviceCoupon?.surplusCount ?? (json['stocknum'] as int?)?.toInt() ?? 0,
      salesCount: (json['monthsale'] as int?)?.toInt() ?? 0,
      marketPrice: _parseDecimal(json['marketprice']),
      mainImageUrl: mainImage,
      description: serviceCoupon?.descriptionHtml ?? '',
      carouselImages: carouselImages,
      // API 原始字段
      productId: _toInt(json['pid']),
      priceCents: _toInt(json['price']), // 积分
      priceDesc: json['pricedesc']?.toString(),
      isTemplate: json['istemplate'] == true || json['istemplate'] == 1,
      isCredit: json['iscredit'] == true || json['iscredit'] == 1,
      productState: _toInt(json['productstate']),
      shipFee: _parseDecimal(json['shipfee']),
      saleUnit: json['saleunit']?.toString(),
      creditCount: _toInt(json['creditcount']),
      productType: CreditProductType.fromJson(json['producttype']),
      baiLiHuiType: json['baiLiHuiType'] != null ? BaiLiHuiProductType.fromJson(json['baiLiHuiType']) : null,
      fuluType: _nullableInt(json['fulutype']),
      templateType: _nullableInt(json['templatetype']),
      auth: json['auth'] == true || json['auth'] == 1,
      authTips: json['authtips']?.toString(),
      datatag: json['datatag']?.toString(),
      specs: _parseList(json['parameter'], CommonPara.fromJson),
      singlePromotion: json['singlepromotion'] is Map ? PromotionInfo.fromJson(Map<String, dynamic>.from(json['singlepromotion'] as Map)) : null,
      giftpromotion: _parseList(json['giftpromotion'], PromotionInfo.fromJson),
      buysendPromotion: _parseList(json['buysendpromotion'], PromotionInfo.fromJson),
      storePromotion: _parseList(json['storepromotion'], PromotionInfo.fromJson),
      coupons: _parseList(json['couponlist'], CouponItem.fromJson),
      serviceCoupon: serviceCoupon,
    );
  }

  static int _toInt(dynamic value) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

  static int? _nullableInt(dynamic value) => value == null ? null : _toInt(value);

  /// 通用 Decimal 解析辅助
  static Decimal _parseDecimal(dynamic v) {
    if (v == null) return Decimal.zero;
    if (v is Decimal) return v;
    if (v is num) return Decimal.parse(v.toString());
    if (v is String) return Decimal.tryParse(v) ?? Decimal.zero;
    return Decimal.zero;
  }

  /// 通用列表解析辅助
  static List<T> _parseList<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) {
    if (json == null) return [];
    if (json is! List) return [];
    return json.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 是否为上架状态（productState == 0）
  bool get isOnSale => productState == 0;

  /// 是否可购买（上架且有权）
  bool get canPurchase => isOnSale && auth;

  /// 格式化市场价显示
  String get marketPriceDisplay => marketPrice > Decimal.zero ? '市场价:¥${marketPrice.toStringAsFixed(2)}' : '';

  /// Mock 数据（开发/测试环境降级使用）
  static final ServiceProductDetail mock = ServiceProductDetail(
    id: 'service_001',
    heroImageUrl: null,
    title: '天佑德电商专供青海环线三日游旅游券（青海三日游）',
    tags: ['旅游券', '三日游'],
    points: 1000,
    remainingStock: 100,
    salesCount: 90000,
    marketPrice: Decimal.parse('760.00'),
    mainImageUrl: 'assets/images/service/service_product_main.png',
    carouselImages: [
      'assets/images/service/service_product_hero_bg.png',
      'assets/images/service/service_product_hero_bg2.png',
      'assets/images/service/service_product_hero_bg3.png',
    ],
    description: '持本旅游券即可兑换青海环线 3 天 2 晚跟团之旅，打卡青海经典核心美景，远离城市喧嚣，沉浸式感受青藏高原辽阔风光。行程轻松不赶路，适合朋友结伴、家庭出游，随团省心出行，不用费心规划路线。',
    productId: 1,
    priceCents: 76000,
    shipFee: Decimal.zero,
    productType: CreditProductType.serviceCouponIntegral,
    isCredit: true,
    productState: 0,
    auth: true,
    specs: [
      CommonPara(id: 1, name: '行程天数', value: '3天2晚'),
      CommonPara(id: 2, name: '出发地', value: '西宁'),
      CommonPara(id: 3, name: '住宿标准', value: '四星酒店'),
    ],
  );
}
