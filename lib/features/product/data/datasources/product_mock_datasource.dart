import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/product_repository.dart';
import '../../../../core/network/api_response.dart';

/// Mock 商品数据源 - 开发/测试环境使用
class MockProductDataSource implements ProductRepository {
  @override
  Future<ApiResponse<HomeProductData>> getHomeProductData() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return ApiResponse.success(
      HomeProductData(
        banners: [
          HomeBanner(
            imageUrl: 'https://picsum.photos/750/360?random=1',
            title: '新人专享',
            actionUrl: '/activity/new-user',
          ),
          HomeBanner(imageUrl: 'https://picsum.photos/750/360?random=2', title: '特产热卖', actionUrl: '/activity/special'),
          HomeBanner(imageUrl: 'https://picsum.photos/750/360?random=3', title: '积分兑换', actionUrl: '/points/mall'),
        ],
        kingKongItems: [
          HomeKingKongItem(iconUrl: '', label: '天佑德自营', actionUrl: '/shop?type=self'),
          HomeKingKongItem(iconUrl: '', label: '青藏特产', actionUrl: '/shop?type=region'),
          HomeKingKongItem(iconUrl: '', label: '水果饮料', actionUrl: '/shop?type=drink'),
          HomeKingKongItem(iconUrl: '', label: '新人礼', actionUrl: '/activity/new-gift'),
          HomeKingKongItem(iconUrl: '', label: '热卖商品', actionUrl: '/shop?type=hot'),
          HomeKingKongItem(iconUrl: '', label: '活动专区', actionUrl: '/activity/list'),
          HomeKingKongItem(iconUrl: '', label: '积分商城', actionUrl: '/points/mall'),
          HomeKingKongItem(iconUrl: '', label: '服务预约', actionUrl: '/service'),
          HomeKingKongItem(iconUrl: '', label: '专属管家', actionUrl: '/service/butler'),
          HomeKingKongItem(iconUrl: '', label: '会员权益', actionUrl: '/member/benefit'),
        ],
        newUserGifts: [
          HomeNewUserGift(title: '满100减20', desc: '新人专享'),
          HomeNewUserGift(title: '满200减50', desc: '满额立减'),
          HomeNewUserGift(title: '首单包邮', desc: '全场通用'),
        ],
        hotProducts: [
          ProductCard(id: '1', imageUrl: 'https://picsum.photos/300/300?random=10', name: '天佑德电商专供海拔系列 2900青稞酒 46度500ml', priceCents: 13990, originalPriceCents: 16800, tag: '自营', salesCount: 1234),
          ProductCard(id: '2', imageUrl: 'https://picsum.photos/300/300?random=11', name: '天佑德青稞酒 经典款 500ml', priceCents: 9800, tag: '自营', salesCount: 888),
          ProductCard(id: '3', imageUrl: 'https://picsum.photos/300/300?random=12', name: '青海藏牛肉干 原味 100g', priceCents: 5800, tag: '青藏特产', salesCount: 2345),
          ProductCard(id: '4', imageUrl: 'https://picsum.photos/300/300?random=13', name: '菜籽油 非转基因 5L装', priceCents: 7900, salesCount: 567),
          ProductCard(id: '5', imageUrl: 'https://picsum.photos/300/300?random=14', name: '天佑德青稞酒 礼盒装 500ml×2', priceCents: 25800, originalPriceCents: 29800, tag: '特价', salesCount: 432),
          ProductCard(id: '6', imageUrl: 'https://picsum.photos/300/300?random=15', name: '青稞饼干 礼盒装 500g', priceCents: 3900, tag: '青藏特产', salesCount: 1890),
          ProductCard(id: '7', imageUrl: 'https://picsum.photos/300/300?random=16', name: '高原枸杞 特级 250g', priceCents: 6800, salesCount: 765),
          ProductCard(id: '8', imageUrl: 'https://picsum.photos/300/300?random=17', name: '天佑德青稞酒 52度 500ml', priceCents: 12800, originalPriceCents: 15800, tag: '自营', salesCount: 999),
          ProductCard(id: '9', imageUrl: 'https://picsum.photos/300/300?random=18', name: '红酒 智利进口 赤霞珠 750ml', priceCents: 19800, salesCount: 321),
          ProductCard(id: '10', imageUrl: 'https://picsum.photos/300/300?random=19', name: '威士忌 单一麦芽 500ml', priceCents: 32800, originalPriceCents: 39800, tag: '自营', salesCount: 156),
          ProductCard(id: '11', imageUrl: 'https://picsum.photos/300/300?random=20', name: '青稞啤酒 330ml×24听', priceCents: 8800, salesCount: 2100),
          ProductCard(id: '12', imageUrl: 'https://picsum.photos/300/300?random=21', name: '牦牛肉干 香辣味 150g', priceCents: 6800, tag: '青藏特产', salesCount: 1567),
        ],
        hotSearchKeywords: ['青稞酒', '牛肉干', '菜籽油', '枸杞', '礼盒', '红酒', '威士忌', '特惠'],
        topicActivities: const {
          '青藏特产': 'https://picsum.photos/750/200?random=20',
          '主食饮料': 'https://picsum.photos/750/200?random=21',
          '天佑德自营': 'https://picsum.photos/750/200?random=22',
        },
        activityBlocks: [
          HomeActivityBlock(id: 'act1', imageUrl: 'https://picsum.photos/400/300?random=30', title: '外商自萋', actionUrl: '/shop?type=self'),
          HomeActivityBlock(id: 'act2', imageUrl: 'https://picsum.photos/400/300?random=31', title: '积分商城', actionUrl: '/points/mall'),
          HomeActivityBlock(id: 'act3', imageUrl: 'https://picsum.photos/400/300?random=32', title: '服务预约', actionUrl: '/service'),
        ],
        topicActivityBlocks: [
          HomeTopicActivityBlock(id: 'ta1', imageUrl: 'https://picsum.photos/400/300?random=33', title: '商品专题活动轮播图', actionUrl: '/topic/qingzang'),
          HomeTopicActivityBlock(id: 'ta2', imageUrl: 'https://picsum.photos/400/300?random=34', title: '商品', actionUrl: '/product/1', product: ProductCard(id: '99', imageUrl: 'https://picsum.photos/300/300?random=99', name: '天仁德青稲酒 精品款 500ml', priceCents: 12800, tag: '自萋', salesCount: 567)),
          HomeTopicActivityBlock(id: 'ta3', imageUrl: 'https://picsum.photos/400/300?random=35', title: '商品', actionUrl: '/product/2', product: ProductCard(id: '98', imageUrl: 'https://picsum.photos/300/300?random=98', name: '高原枪李 特级 250g', priceCents: 6800, tag: '青藏特产', salesCount: 765)),
        ],
        monthlyBenefits: [
          HomeMonthlyBenefit(id: '1', title: '生日积分翻倍', imageUrl: null),
          HomeMonthlyBenefit(id: '2', title: '节日积分翻倍', imageUrl: null),
          HomeMonthlyBenefit(id: '3', title: '会员专属折扣', imageUrl: null),
          HomeMonthlyBenefit(id: '4', title: '免费配送券', imageUrl: null),
          HomeMonthlyBenefit(id: '5', title: '积分兑好礼', imageUrl: null),
        ],
      ),
    );
  }

  @override
  Future<ApiResponse<ProductDetail>> getProductDetail(String productId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.success(ProductDetail(
      id: productId, name: '天佑德青稞酒', description: '精选高原青稞酿造', images: ['https://picsum.photos/600/600?random=30'],
      priceCents: 13990, skus: [ProductSku(id: 's1', name: '500ml', priceCents: 13990, stock: 100, attributes: {'规格': '500ml'})],
      specs: [ProductSpec(key: '产地', value: '青海'), ProductSpec(key: '度数', value: '46度')],
    ));
  }

  @override
  Future<ApiResponse<ProductListResult>> getProductList({required int page, required int pageSize, String? categoryId, String? keyword, String? sortBy}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allProducts = [
      ProductCard(id: '1', imageUrl: 'https://picsum.photos/300/300?random=10', name: '天佑德电商专供海拔系列 2900青稞酒 46度500ml', priceCents: 13990, originalPriceCents: 16800, tag: '自营', salesCount: 1234),
      ProductCard(id: '2', imageUrl: 'https://picsum.photos/300/300?random=11', name: '天佑德青稞酒 经典款 500ml', priceCents: 9800, tag: '自营', salesCount: 888),
      ProductCard(id: '3', imageUrl: 'https://picsum.photos/300/300?random=12', name: '青海藏牛肉干 原味 100g', priceCents: 5800, tag: '青藏特产', salesCount: 2345),
      ProductCard(id: '4', imageUrl: 'https://picsum.photos/300/300?random=13', name: '菜籽油 非转基因 5L装', priceCents: 7900, salesCount: 567),
      ProductCard(id: '5', imageUrl: 'https://picsum.photos/300/300?random=14', name: '天佑德青稞酒 礼盒装 500ml×2', priceCents: 25800, originalPriceCents: 29800, tag: '特价', salesCount: 432),
      ProductCard(id: '6', imageUrl: 'https://picsum.photos/300/300?random=15', name: '青稞饼干 礼盒装 500g', priceCents: 3900, tag: '青藏特产', salesCount: 1890),
      ProductCard(id: '7', imageUrl: 'https://picsum.photos/300/300?random=16', name: '高原枸杞 特级 250g', priceCents: 6800, salesCount: 765),
      ProductCard(id: '8', imageUrl: 'https://picsum.photos/300/300?random=17', name: '天佑德青稞酒 52度 500ml', priceCents: 12800, originalPriceCents: 15800, tag: '自营', salesCount: 999),
      ProductCard(id: '9', imageUrl: 'https://picsum.photos/300/300?random=18', name: '红酒 智利进口 赤霞珠 750ml', priceCents: 19800, salesCount: 321),
      ProductCard(id: '10', imageUrl: 'https://picsum.photos/300/300?random=19', name: '威士忌 单一麦芽 500ml', priceCents: 32800, originalPriceCents: 39800, tag: '自营', salesCount: 156),
      ProductCard(id: '11', imageUrl: 'https://picsum.photos/300/300?random=20', name: '青稞啤酒 330ml×24听', priceCents: 8800, salesCount: 2100),
      ProductCard(id: '12', imageUrl: 'https://picsum.photos/300/300?random=21', name: '牦牛肉干 香辣味 150g', priceCents: 6800, tag: '青藏特产', salesCount: 1567),
    ];
    var filtered = allProducts;
    if (categoryId != null) {
      if (categoryId == 'self') filtered = filtered.where((p) => p.tag == '自营').toList();
      else if (categoryId == 'region') filtered = filtered.where((p) => p.tag == '青藏特产').toList();
      else if (categoryId == 'hot') filtered = filtered.where((p) => (p.salesCount ?? 0) > 1000).toList();
    }
    if (keyword != null && keyword.isNotEmpty) filtered = filtered.where((p) => p.name.contains(keyword)).toList();
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    final paginated = start < filtered.length ? filtered.sublist(start, end.clamp(0, filtered.length)) : [];
    return ApiResponse.success(ProductListResult(products: paginated.cast<ProductCard>(), total: filtered.length, page: page, pageSize: pageSize, hasMore: end < filtered.length));
  }

  @override
  Future<ApiResponse<List<ProductCategory>>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success([
      ProductCategory(id: 'all', label: '全部', sortOrder: 0),
      ProductCategory(id: 'self', label: '天佑德自营', sortOrder: 1),
      ProductCategory(id: 'region', label: '青藏特产', sortOrder: 2),
      ProductCategory(id: 'drink', label: '水果饮料', sortOrder: 3),
      ProductCategory(id: 'hot', label: '热卖商品', sortOrder: 4),
    ]);
  }

  @override
  Future<ApiResponse<ProductListResult>> searchProducts({required String keyword, required int page, required int pageSize}) async {
    return getProductList(page: page, pageSize: pageSize, keyword: keyword);
  }
}

/// MockProductRepository Provider - 开发环境使用
final mockProductRepositoryProvider = Provider<ProductRepository>((ref) => MockProductDataSource());