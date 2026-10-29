/// 积分商城服务商品详情数据模型（API 对接后替换）
///
/// 接口：POST /api/product/getproductinfo
library;

import 'package:decimal/decimal.dart';

import 'get_recommend_product_list_model.dart';

int _jsonInt(dynamic value) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

double _jsonDouble(dynamic value) => _jsonDoubleOrNull(value) ?? 0.0;

double? _jsonDoubleOrNull(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool _jsonBool(dynamic value) => value == true || value == 1 || value == '1' || value == 'true';

// ── BaiLiHui 产品类型枚举 ────────────────────────────────────────────────────

enum BaiLiHuiProductType {
  selfOperatedPhysical(0), // 自营实物
  electronicCard(1), // 电子卡券
  phoneRecharge(2), // 直充话费
  ecommerce(3); // 电商

  const BaiLiHuiProductType(this.value);
  final int value;

  factory BaiLiHuiProductType.fromJson(dynamic json) {
    final value = _jsonInt(json);
    return _byValue[value] ?? BaiLiHuiProductType.selfOperatedPhysical;
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
      promotionId: _jsonInt(json['promotionid']),
      promotionTitle: json['promotiontitle'] as String? ?? '',
      activityType: _jsonInt(json['activitytype']),
      promotionType: _jsonInt(json['promotiontype']),
      descr: json['descr'] as String?,
      discountValue: _jsonDoubleOrNull(json['discountvalue']),
      discount: _jsonDoubleOrNull(json['discount']),
      disAmount: _jsonDoubleOrNull(json['disamount']),
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
    return PromotionGiftProduct(pid: _jsonInt(json['pid']), pname: json['pname'] as String? ?? '', num: _jsonInt(json['num']));
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
      storeId: _jsonInt(json['storeid']),
      couponTypeId: _jsonInt(json['coupontypeid']),
      money: _jsonDouble(json['money']),
      limitLowAmount: _jsonDouble(json['limitlowamount']),
      startTime: _parseDateTime(json['starttime']),
      endTime: _parseDateTime(json['endtime']),
      isReceive: _jsonBool(json['isreceive']),
      allowMultTimes: _jsonBool(json['allowmulttimes']),
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
    return CommonPara(id: _jsonInt(json['id']), name: json['name'] as String? ?? '', value: json['value']?.toString() ?? '');
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
      couponConfigId: _jsonInt(json['couponconfigid']),
      couponName: json['couponname'] as String?,
      descriptionHtml: json['descriptionhtml'] as String?,
      surplusCount: _jsonInt(json['surpluscount']),
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
///   tags              → parameter[x].value（商品标签展示列表）
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

  factory ServiceProductDetail.fromJson(Map<String, dynamic> json, {int? fallbackProductId}) {
    final carouselRaw = json['carouselimg'];
    final carouselimgs = carouselRaw is List ? carouselRaw : const <dynamic>[];
    final carouselImages = carouselimgs.map((e) => e.toString()).where((u) => u.isNotEmpty).toList();
    final mainImage = carouselImages.isNotEmpty ? carouselImages.first : '';
    final heroImage = carouselImages.length > 1 ? carouselImages[1] : mainImage;

    final serviceCouponMap = json['servicecoupon'] is Map ? Map<String, dynamic>.from(json['servicecoupon'] as Map) : null;
    final serviceCoupon = serviceCouponMap != null ? ServiceCouponInfo.fromJson(serviceCouponMap) : null;
    final productId = json['pid'] == null ? (fallbackProductId ?? 0) : _jsonInt(json['pid']);

    return ServiceProductDetail(
      id: productId == 0 ? '' : productId.toString(),
      heroImageUrl: heroImage.isEmpty ? null : heroImage,
      title: json['name'] as String? ?? '',
      tags: const [],
      //tags: _parseList(json['parameter'], CommonPara.fromJson).map((parameter) => parameter.value).where((value) => value.trim().isNotEmpty).toList(),
      points: _jsonInt(json['price']), // 积分
      remainingStock: serviceCoupon?.surplusCount ?? _jsonInt(json['stocknum']),
      salesCount: _jsonInt(json['monthsale']),
      marketPrice: _parseDecimal(json['marketprice']),
      mainImageUrl: mainImage,
      description: serviceCoupon?.descriptionHtml ?? '',
      carouselImages: carouselImages,
      // API 原始字段
      productId: productId,
      priceCents: _jsonInt(json['price']), // 积分
      priceDesc: json['pricedesc']?.toString(),
      isTemplate: _jsonBool(json['istemplate']),
      isCredit: _jsonBool(json['iscredit']),
      productState: _jsonInt(json['productstate']),
      shipFee: _parseDecimal(json['shipfee']),
      saleUnit: json['saleunit']?.toString(),
      creditCount: _jsonInt(json['creditcount']),
      productType: CreditProductType.fromJson(json['producttype']),
      baiLiHuiType: json['baiLiHuiType'] != null ? BaiLiHuiProductType.fromJson(json['baiLiHuiType']) : null,
      fuluType: _nullableInt(json['fulutype']),
      templateType: _nullableInt(json['templatetype']),
      auth: _jsonBool(json['auth']),
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

  static int? _nullableInt(dynamic value) => value == null ? null : _jsonInt(value);

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
}
