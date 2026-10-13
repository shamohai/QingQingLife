/// 继续加购候选商品模型
///
/// 对应接口：POST /api/groupmall/sharecart/getcondidateproductlist
/// 请求：{"sharecartid": int, "pageindex": int, "pagesize": int}
///
/// 响应（扁平格式，ApiResponse 自动剥离 result/descr/datatag）：
/// ```
/// {
///   "totalcount": int,
///   "products": [
///     {
///       "productid": int,
///       "productname": string,
///       "imgurl": string,
///       "price": decimal,
///       "marketprice": decimal,
///       "cartnum": int,
///       "mincount": int,
///       "maxcount": int,
///       "num": int,
///       "pricedesc": string,
///       "marketpricedesc": string,
///       "saleunit": string
///     }
///   ]
/// }

/// 候选商品（继续加购区）
class CandidateProduct {
  final int productId;
  final String productName;
  final String imgUrl;

  /// 单价（元）
  final double price;

  /// 市场价（元）
  final double marketPrice;

  /// 当前购物车中数量
  final int cartNum;

  /// 最少可购数量
  final int minCount;

  /// 最多可购数量
  final int maxCount;

  /// 默认数量
  final int defaultQuantity;

  /// 价格描述（如 "¥199.00/瓶"）
  final String priceDesc;

  /// 市场价描述
  final String marketPriceDesc;

  /// 销售单位
  final String saleUnit;

  const CandidateProduct({
    required this.productId,
    required this.productName,
    required this.imgUrl,
    required this.price,
    required this.marketPrice,
    required this.cartNum,
    required this.minCount,
    required this.maxCount,
    required this.defaultQuantity,
    this.priceDesc = '',
    this.marketPriceDesc = '',
    this.saleUnit = '',
  });

  factory CandidateProduct.fromJson(Map<String, dynamic> json) {
    return CandidateProduct(
      productId: (json['productid'] as num?)?.toInt() ?? 0,
      productName: json['productname'] as String? ?? '',
      imgUrl: json['imgurl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      marketPrice: (json['marketprice'] as num?)?.toDouble() ?? 0.0,
      cartNum: (json['cartnum'] as num?)?.toInt() ?? 0,
      minCount: (json['mincount'] as num?)?.toInt() ?? 1,
      maxCount: (json['maxcount'] as num?)?.toInt() ?? 99,
      defaultQuantity: (json['num'] as num?)?.toInt() ?? 1,
      priceDesc: json['pricedesc'] as String? ?? '',
      marketPriceDesc: json['marketpricedesc'] as String? ?? '',
      saleUnit: json['saleunit'] as String? ?? '',
    );
  }

  CandidateProduct copyWith({int? cartNum}) {
    return CandidateProduct(
      productId: productId,
      productName: productName,
      imgUrl: imgUrl,
      price: price,
      marketPrice: marketPrice,
      cartNum: cartNum ?? this.cartNum,
      minCount: minCount,
      maxCount: maxCount,
      defaultQuantity: defaultQuantity,
      priceDesc: priceDesc,
      marketPriceDesc: marketPriceDesc,
      saleUnit: saleUnit,
    );
  }
}

/// getcondidateproductlist 响应体
class CandidateProductList {
  final int totalCount;
  final List<CandidateProduct> products;

  const CandidateProductList({required this.totalCount, required this.products});

  factory CandidateProductList.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'] as List<dynamic>? ?? [];
    return CandidateProductList(
      totalCount: (json['totalcount'] as num?)?.toInt() ?? 0,
      products: productsJson.map((e) => CandidateProduct.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
