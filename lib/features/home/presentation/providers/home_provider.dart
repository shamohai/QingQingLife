import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/home_banner_item.dart';
import '../../data/models/home_kingkong_item.dart';
import '../../data/models/home_new_user_gift.dart';
import '../../data/models/product_card_model.dart';

/// 首页状态枚举
enum HomeLoadingState { loading, loaded, error }

/// 首页数据 Provider
/// 一期使用 Mock 数据，后续接入真实 API 时替换
final homeDataProvider = Provider<HomeDataProvider>((ref) => HomeDataProvider());

class HomeDataProvider {
  const HomeDataProvider();

  // 轮播图列表
  List<HomeBannerItem> get banners => [
    const HomeBannerItem(imageUrl: 'https://picsum.photos/750/360?random=1', title: '新人专享', actionUrl: '/activity/new-user'),
    const HomeBannerItem(imageUrl: 'https://picsum.photos/750/360?random=2', title: '特产热卖', actionUrl: '/activity/special'),
    const HomeBannerItem(imageUrl: 'https://picsum.photos/750/360?random=3', title: '积分兑换', actionUrl: '/points/mall'),
  ];

  // 金刚区导航图标
  List<HomeKingKongItem> get kingKongItems => [
    const HomeKingKongItem(iconUrl: '', label: '天佑德自营', actionUrl: '/shop?type=self'),
    const HomeKingKongItem(iconUrl: '', label: '青藏特产', actionUrl: '/shop?type=region'),
    const HomeKingKongItem(iconUrl: '', label: '水果饮料', actionUrl: '/shop?type=drink'),
    const HomeKingKongItem(iconUrl: '', label: '新人礼', actionUrl: '/activity/new-gift'),
    const HomeKingKongItem(iconUrl: '', label: '热卖商品', actionUrl: '/shop?type=hot'),
    const HomeKingKongItem(iconUrl: '', label: '活动专区', actionUrl: '/activity/list'),
  ];

  // 新人礼（优惠券）
  List<HomeNewUserGift> get newUserGifts => [
    const HomeNewUserGift(title: '满100减20', desc: '新人专享'),
    const HomeNewUserGift(title: '满200减50', desc: '满额立减'),
    const HomeNewUserGift(title: '首单包邮', desc: '全场通用'),
  ];

  // 热卖商品列表（Mock）
  List<ProductCardModel> get hotProducts => [
    const ProductCardModel(id: '1', imageUrl: 'https://picsum.photos/300/300?random=10', name: '天佑德电商专供海拔系列 2900青稞酒 46度500ml', priceCents: 13990, originalPriceCents: 16800, tag: '自营', salesCount: 1234),
    const ProductCardModel(id: '2', imageUrl: 'https://picsum.photos/300/300?random=11', name: '天佑德青稞酒 经典款 500ml', priceCents: 9800, tag: '自营', salesCount: 888),
    const ProductCardModel(id: '3', imageUrl: 'https://picsum.photos/300/300?random=12', name: '青海藏牛肉干 原味 100g', priceCents: 5800, tag: '青藏特产', salesCount: 2345),
    const ProductCardModel(id: '4', imageUrl: 'https://picsum.photos/300/300?random=13', name: '菜籽油 非转基因 5L装', priceCents: 7900, salesCount: 567),
    const ProductCardModel(id: '5', imageUrl: 'https://picsum.photos/300/300?random=14', name: '天佑德青稞酒 礼盒装 500ml×2', priceCents: 25800, originalPriceCents: 29800, tag: '特价', salesCount: 432),
    const ProductCardModel(id: '6', imageUrl: 'https://picsum.photos/300/300?random=15', name: '青稞饼干 礼盒装 500g', priceCents: 3900, tag: '青藏特产', salesCount: 1890),
    const ProductCardModel(id: '7', imageUrl: 'https://picsum.photos/300/300?random=16', name: '高原枸杞 特级 250g', priceCents: 6800, salesCount: 765),
    const ProductCardModel(id: '8', imageUrl: 'https://picsum.photos/300/300?random=17', name: '天佑德青稞酒 52度 500ml', priceCents: 12800, originalPriceCents: 15800, tag: '自营', salesCount: 999),
  ];

  // 热搜词
  List<String> get hotSearchKeywords => ['青稞酒', '牛肉干', '菜籽油', '枸杞', '礼盒', '红酒', '威士忌', '特惠'];

  // 专题活动
  final Map<String, String> topicActivities = const {
    '青藏特产': 'https://picsum.photos/750/200?random=20',
    '主食饮料': 'https://picsum.photos/750/200?random=21',
    '天佑德自营': 'https://picsum.photos/750/200?random=22',
  };
}