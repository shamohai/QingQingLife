/// 获取积分商城商品分类列表（GetCreditProductCategory）响应模型
///
/// 接口：POST /api/product/getcreditproductcategory
library;

/// 单个分类项
class CreditProductCategory {
  final int categoryId;
  final String categoryName;

  const CreditProductCategory({required this.categoryId, required this.categoryName});

  /// 客户端补全的"全部分类"项，categoryId = 0
  static const CreditProductCategory all = CreditProductCategory(categoryId: 0, categoryName: '全部分类');
}

/// 分类列表响应数据
class CreditProductCategoryData {
  final List<CreditProductCategory> categories;

  const CreditProductCategoryData({required this.categories});

  factory CreditProductCategoryData.fromJson(Map<String, dynamic> json) {
    final raw = json['categorylist'] as List<dynamic>? ?? [];
    final parsed = raw.map((e) {
      final m = e as Map<String, dynamic>;
      return CreditProductCategory(categoryId: (m['categoryid'] as num?)?.toInt() ?? 0, categoryName: (m['categoryname'] as String? ?? '').trim());
    }).toList();
    // 过滤掉后端可能意外返回的 categoryId == 0 项，避免与客户端补全项重复
    final filtered = parsed.where((c) => c.categoryId != 0).toList();
    // 客户端在列表最前面插入"全部分类"
    return CreditProductCategoryData(categories: [CreditProductCategory.all, ...filtered]);
  }
}
