/// 获取青稞粒商品列表（GetCreditProductList）响应模型
///
/// 接口：POST /api/product/getcreditproductlist
library;

import 'get_recommend_product_list_model.dart';

/// 青稞粒商品列表项
class CreditProductItem {
  final int productId;
  final CreditProductType productType;
  final String productName;
  final String imgUrl;
  final int creditPrice;
  final int? stock;
  final int praise;
  final int commentCount;
  final int storeId;
  final String? warning;
  /// 是否是积分产品（Boolean 字段：iscredit）
  final bool isCredit;

  const CreditProductItem({
    required this.productId,
    required this.productType,
    required this.productName,
    required this.imgUrl,
    required this.creditPrice,
    this.stock,
    required this.praise,
    required this.commentCount,
    required this.storeId,
    this.warning,
    this.isCredit = false,
  });

  bool get isService => isCredit;

  factory CreditProductItem.fromJson(Map<String, dynamic> json) {
    return CreditProductItem(
      productId: (json['productid'] as num?)?.toInt() ?? 0,
      productType: CreditProductType.fromJson(json['producttype']),
      productName: json['productname'] as String? ?? '',
      imgUrl: json['imgurl'] as String? ?? '',
      creditPrice: (json['creditcount'] as num?)?.toInt() ?? (json['creditprice'] as num?)?.toInt() ?? 0,
      stock: json['stock'] != null ? (json['stock'] as num).toInt() : null,
      praise: (json['praise'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentcount'] as num?)?.toInt() ?? 0,
      storeId: (json['storeid'] as num?)?.toInt() ?? 0,
      warning: json['warning'] as String?,
      isCredit: json['iscredit'] == true || json['iscredit'] == 1 || json['iscredit'] == 'true',
    );
  }
}

/// 青稞粒商品列表响应数据
class CreditProductListData {
  final List<CreditProductItem> products;
  final int total;
  final int page;
  final int pageSize;

  const CreditProductListData({required this.products, required this.total, required this.page, required this.pageSize});

  bool get hasMore {
    if (products.isEmpty) return false;
    if (pageSize > 0 && products.length < pageSize) return false;
    return page * pageSize < total;
  }

  factory CreditProductListData.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'] as List<dynamic>? ?? [];
    return CreditProductListData(
      products: productsJson.map((e) => CreditProductItem.fromJson(e as Map<String, dynamic>)).toList(),
      total: (json['totalcount'] as num?)?.toInt() ?? productsJson.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pagesize'] as num?)?.toInt() ?? productsJson.length,
    );
  }
}
