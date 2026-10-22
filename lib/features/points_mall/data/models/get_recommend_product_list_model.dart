/// 推荐商品接口响应模型（GetRecommendProductList）
///
/// 接口：POST /api/product/getrecommendproductlist
/// 用于积分商城热门兑换商品加载。
library;

/// 商品类型，对应后端 BrnMall.Core.ProductType 枚举。
///
/// 来源：http://10.1.1.52:8082/doc/ApiDocumentation.aspx?enum=1&id=BrnMall.Core.ProductType
enum CreditProductType {
  /// 畅销产品
  ordinary(0),
  /// 定制酒商品
  template(1),
  /// 积分商品
  integral(2),
  /// 旅游商品
  travel(3),
  /// 礼品卡
  giftCard(4),
  /// 老酒商品
  oldWine(5),
  /// 实物礼品（抽奖商品）
  gift(6),
  /// 福禄商品
  fuluProduct(7),
  /// 会员商品（已过时）
  memberProduct(8),
  /// 特供商品
  specialSupply(9),
  /// 积分兑换服务券
  serviceCouponIntegral(10),
  /// 积分兑换服务券（销售类）
  serviceCouponSale(11),
  /// 百礼汇积分商品
  baiLiHuiProduct(30);

  const CreditProductType(this.value);
  final int value;

  /// 从 JSON 字符串/整数解析，未知值返回 null
  factory CreditProductType.fromJson(dynamic json) {
    final int? v = json is int ? json : (json as num?)?.toInt();
    return _byValue[v] ?? CreditProductType.ordinary;
  }

  static final Map<int, CreditProductType> _byValue = {
    for (final e in CreditProductType.values) e.value: e,
  };
}

class CreditMallProduct {
  final int productId;
  final CreditProductType productType;
  final String productName;
  final String? productSn;
  final String imgUrl;
  final double price;
  final double marketPrice;
  final int creditPrice;
  final int prepaidPrice;
  final String? saleUnit;
  final int praise;
  final int commentCount;
  final int storeId;
  /// 是否是积分产品（Boolean 字段：iscredit）
  final bool isCredit;

  const CreditMallProduct({
    required this.productId,
    required this.productType,
    required this.productName,
    this.productSn,
    required this.imgUrl,
    required this.price,
    required this.marketPrice,
    required this.creditPrice,
    required this.prepaidPrice,
    this.saleUnit,
    required this.praise,
    required this.commentCount,
    required this.storeId,
    this.isCredit = false,
  });

  bool get isService => isCredit;

  factory CreditMallProduct.fromJson(Map<String, dynamic> json) {
    return CreditMallProduct(
      productId: (json['productid'] as num?)?.toInt() ?? 0,
      productType: CreditProductType.fromJson(json['producttype']),
      productName: json['productname'] as String? ?? '',
      productSn: json['productsn'] as String?,
      imgUrl: json['imgurl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      marketPrice: (json['marketprice'] as num?)?.toDouble() ?? 0.0,
      creditPrice: (json['creditprice'] as num?)?.toInt() ?? 0,
      prepaidPrice: (json['prepaidprice'] as num?)?.toInt() ?? 0,
      saleUnit: json['saleunit'] as String?,
      praise: (json['praise'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentcount'] as num?)?.toInt() ?? 0,
      storeId: (json['storeid'] as num?)?.toInt() ?? 0,
      isCredit: json['iscredit'] == true || json['iscredit'] == 1 || json['iscredit'] == 'true',
    );
  }
}
