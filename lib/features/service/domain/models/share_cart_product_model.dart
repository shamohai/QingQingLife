/// 共享购物车商品模型
///
/// 对应接口：POST /api/groupmall/sharecart/getsharecartproductlist
/// 请求：{"sharecartid": int, "listtype": 1, "pid": int?}
///
/// 响应（扁平格式，ApiResponse 自动剥离 result/descr/datatag）：
/// ```
/// {
///   "cansubmit": bool,
///   "verifymsg": string,
///   "totalcount": int,
///   "list": [
///     {
///       "pid": int,
///       "productname": string,
///       "image": string,
///       "price": decimal,
///       "stock": int,
///       "count": int,
///       "fullprice": string,
///       "fullmarketprice": string
///     }
///   ]
/// }
/// ```

/// 购物车中的单个商品
class ShareCartProduct {
  /// 商品 ID（pid）
  final int pid;

  /// 商品名称
  final String productName;

  /// 商品图片 URL
  final String image;

  /// 单价（元，后端 Decimal）
  final double price;

  /// 库存
  final int stock;

  /// 购物车中的数量
  final int count;

  /// 带单位的价格字符串（如 "¥199.00"）
  final String fullPrice;

  /// 带单位的市场价字符串
  final String fullMarketPrice;

  /// 是否已勾选（纯前端本地状态，后端不返回）
  final bool selected;

  const ShareCartProduct({
    required this.pid,
    required this.productName,
    required this.image,
    required this.price,
    required this.stock,
    required this.count,
    this.fullPrice = '',
    this.fullMarketPrice = '',
    this.selected = true,
  });

  ShareCartProduct copyWith({bool? selected, int? count}) {
    return ShareCartProduct(
      pid: pid,
      productName: productName,
      image: image,
      price: price,
      stock: stock,
      count: count ?? this.count,
      fullPrice: fullPrice,
      fullMarketPrice: fullMarketPrice,
      selected: selected ?? this.selected,
    );
  }

  factory ShareCartProduct.fromJson(Map<String, dynamic> json) {
    return ShareCartProduct(
      pid: (json['pid'] as num?)?.toInt() ?? 0,
      productName: json['productname'] as String? ?? '',
      image: json['image'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 1,
      fullPrice: json['fullprice'] as String? ?? '',
      fullMarketPrice: json['fullmarketprice'] as String? ?? '',
    );
  }
}

/// getsharecartproductlist 响应体
class ShareCartProductList {
  final bool canSubmit;
  final String verifyMsg;
  final int totalCount;
  final List<ShareCartProduct> list;

  const ShareCartProductList({
    required this.canSubmit,
    required this.verifyMsg,
    required this.totalCount,
    required this.list,
  });

  factory ShareCartProductList.fromJson(Map<String, dynamic> json) {
    final listJson = json['list'] as List<dynamic>? ?? [];
    return ShareCartProductList(
      canSubmit: json['cansubmit'] as bool? ?? true,
      verifyMsg: json['verifymsg'] as String? ?? '',
      totalCount: (json['totalcount'] as num?)?.toInt() ?? 0,
      list: listJson.map((e) => ShareCartProduct.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
