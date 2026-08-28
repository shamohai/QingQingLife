import '../../../../core/network/api_response.dart';

/// 商品仓库接口
abstract class ProductRepository {
  /// 获取首页商品数据（轮播、金刚区、热卖等）
  Future<ApiResponse<HomeProductData>> getHomeProductData();

  /// 获取商品详情
  Future<ApiResponse<ProductDetail>> getProductDetail(String productId);

  /// 获取商品列表（分页）
  Future<ApiResponse<ProductListResult>> getProductList({
    required int page,
    required int pageSize,
    String? categoryId,
    String? keyword,
    String? sortBy,
  });

  /// 获取商品分类
  Future<ApiResponse<List<ProductCategory>>> getCategories();

  /// 搜索商品
  Future<ApiResponse<ProductListResult>> searchProducts({
    required String keyword,
    required int page,
    required int pageSize,
  });
}

/// 首页商品聚合数据
class HomeProductData {
  final List<HomeBanner> banners;
  final List<HomeKingKongItem> kingKongItems;
  final List<HomeNewUserGift> newUserGifts;
  final List<ProductCard> hotProducts;
  final List<String> hotSearchKeywords;
  final Map<String, String> topicActivities;
  final List<HomeMonthlyBenefit> monthlyBenefits;
  final List<HomeActivityBlock> activityBlocks;
  final List<HomeTopicActivityBlock> topicActivityBlocks;

  const HomeProductData({
    required this.banners,
    required this.kingKongItems,
    required this.newUserGifts,
    required this.hotProducts,
    required this.hotSearchKeywords,
    required this.topicActivities,
    required this.monthlyBenefits,
    required this.activityBlocks,
    required this.topicActivityBlocks,
  });
}

/// 首页轮播图
class HomeBanner {
  final String imageUrl;
  final String title;
  final String actionUrl;

  const HomeBanner({required this.imageUrl, required this.title, required this.actionUrl});
}

/// 首页金刚区项
class HomeKingKongItem {
  final String iconUrl;
  final String label;
  final String? actionUrl;

  const HomeKingKongItem({required this.iconUrl, required this.label, this.actionUrl});
}

/// 首页新人礼
class HomeNewUserGift {
  final String title;
  final String? desc;
  final String? imageUrl;
  final String? actionUrl;

  const HomeNewUserGift({required this.title, this.desc, this.imageUrl, this.actionUrl});
}

/// 每月权益
class HomeMonthlyBenefit {
  final String id;
  final String title;
  final String? imageUrl;
  final String? actionUrl;

  const HomeMonthlyBenefit({required this.id, required this.title, this.imageUrl, this.actionUrl});
}


/// 活动模块块（左一右二非对称布局）
class HomeActivityBlock {
  final String id;
  final String? imageUrl;
  final String title;
  final String? actionUrl;

  const HomeActivityBlock({
    required this.id,
    this.imageUrl,
    required this.title,
    this.actionUrl,
  });
}

/// 商品专题活动块（含商品卡片）
class HomeTopicActivityBlock {
  final String id;
  final String? imageUrl;
  final String title;
  final String? actionUrl;
  final ProductCard? product;

  const HomeTopicActivityBlock({
    required this.id,
    this.imageUrl,
    required this.title,
    this.actionUrl,
    this.product,
  });
}

/// 商品卡片（列表展示用）
class ProductCard {
  final String id;
  final String imageUrl;
  final String name;
  final int priceCents;
  final int? originalPriceCents;
  final String? tag;
  final int? salesCount;

  const ProductCard({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.priceCents,
    this.originalPriceCents,
    this.tag,
    this.salesCount,
  });
}

/// 商品详情
class ProductDetail {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final int priceCents;
  final int? originalPriceCents;
  final List<ProductSku> skus;
  final List<ProductSpec> specs;
  final String? brand;
  final String? origin;

  const ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.priceCents,
    this.originalPriceCents,
    required this.skus,
    required this.specs,
    this.brand,
    this.origin,
  });
}

/// 商品 SKU
class ProductSku {
  final String id;
  final String name;
  final int priceCents;
  final int stock;
  final Map<String, String> attributes;

  const ProductSku({required this.id, required this.name, required this.priceCents, required this.stock, required this.attributes});
}

/// 商品规格参数
class ProductSpec {
  final String key;
  final String value;

  const ProductSpec({required this.key, required this.value});
}

/// 分页商品列表结果
class ProductListResult {
  final List<ProductCard> products;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const ProductListResult({required this.products, required this.total, required this.page, required this.pageSize, required this.hasMore});
}

/// 商品分类
class ProductCategory {
  final String id;
  final String label;
  final String? iconUrl;
  final int sortOrder;

  const ProductCategory({required this.id, required this.label, this.iconUrl, required this.sortOrder});
}
