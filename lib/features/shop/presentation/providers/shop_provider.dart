import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 商品数据（特色商城用，与首页共享同一结构）
class ShopProduct {
  final String id;
  final String imageUrl;
  final String name;
  final int priceCents;
  final int? originalPriceCents;
  final String? tag;
  final int? salesCount;

  const ShopProduct({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.priceCents,
    this.originalPriceCents,
    this.tag,
    this.salesCount,
  });
}

/// 分类数据
class ShopCategory {
  final String id;
  final String label;
  final IconData icon;

  const ShopCategory({required this.id, required this.label, required this.icon});
}

/// 特色商城数据 Provider
final shopDataProvider = Provider<ShopDataProvider>((ref) => const ShopDataProvider());

class ShopDataProvider {
  const ShopDataProvider();

  // 分类列表
  List<ShopCategory> get categories => const [
    ShopCategory(id: 'all', label: '全部', icon: Icons.apps_outlined),
    ShopCategory(id: 'featured', label: '特色推荐', icon: Icons.star_border),
    ShopCategory(id: 'self', label: '天佑德自营', icon: Icons.verified),
    ShopCategory(id: 'region', label: '青藏特产', icon: Icons.nature),
    ShopCategory(id: 'drink', label: '水果饮料', icon: Icons.local_drink),
    ShopCategory(id: 'gift', label: '礼盒装', icon: Icons.card_giftcard),
    ShopCategory(id: 'hot', label: '热卖商品', icon: Icons.whatshot),
  ];

  // 全部商品
  List<ShopProduct> get allProducts => const [
    ShopProduct(id: 's1', imageUrl: 'https://picsum.photos/300/300?random=50', name: '天佑德电商专供海拔系列 2900青稞酒 46度500ml', priceCents: 13990, originalPriceCents: 16800, tag: '自营', salesCount: 1234),
    ShopProduct(id: 's2', imageUrl: 'https://picsum.photos/300/300?random=51', name: '天佑德青稞酒 经典款 500ml', priceCents: 9800, tag: '自营', salesCount: 888),
    ShopProduct(id: 's3', imageUrl: 'https://picsum.photos/300/300?random=52', name: '青海藏牛肉干 原味 100g', priceCents: 5800, tag: '青藏特产', salesCount: 2345),
    ShopProduct(id: 's4', imageUrl: 'https://picsum.photos/300/300?random=53', name: '菜籽油 非转基因 5L装', priceCents: 7900, salesCount: 567),
    ShopProduct(id: 's5', imageUrl: 'https://picsum.photos/300/300?random=54', name: '天佑德青稞酒 礼盒装 500ml×2', priceCents: 25800, originalPriceCents: 29800, tag: '特价', salesCount: 432),
    ShopProduct(id: 's6', imageUrl: 'https://picsum.photos/300/300?random=55', name: '青稞饼干 礼盒装 500g', priceCents: 3900, tag: '青藏特产', salesCount: 1890),
    ShopProduct(id: 's7', imageUrl: 'https://picsum.photos/300/300?random=56', name: '高原枸杞 特级 250g', priceCents: 6800, salesCount: 765),
    ShopProduct(id: 's8', imageUrl: 'https://picsum.photos/300/300?random=57', name: '天佑德青稞酒 52度 500ml', priceCents: 12800, originalPriceCents: 15800, tag: '自营', salesCount: 999),
    ShopProduct(id: 's9', imageUrl: 'https://picsum.photos/300/300?random=58', name: '红酒 智利进口 赤霞珠 750ml', priceCents: 19800, salesCount: 321),
    ShopProduct(id: 's10', imageUrl: 'https://picsum.photos/300/300?random=59', name: '威士忌 单一麦芽 500ml', priceCents: 32800, originalPriceCents: 39800, tag: '自营', salesCount: 156),
    ShopProduct(id: 's11', imageUrl: 'https://picsum.photos/300/300?random=60', name: '青稞啤酒 330ml×24听', priceCents: 8800, salesCount: 2100),
    ShopProduct(id: 's12', imageUrl: 'https://picsum.photos/300/300?random=61', name: '牦牛肉干 香辣味 150g', priceCents: 6800, tag: '青藏特产', salesCount: 1567),
  ];

  List<String> get hotSearchKeywords => ['青稞酒', '牛肉干', '菜籽油', '枸杞', '礼盒', '红酒', '特惠'];

  // 按分类过滤商品
  List<ShopProduct> getProductsByCategory(String categoryId) {
    if (categoryId == 'all') return allProducts;
    return allProducts.where((p) {
      if (categoryId == 'featured') return p.salesCount != null && p.salesCount! > 500;
      if (categoryId == 'self') return p.tag == '自营';
      if (categoryId == 'region') return p.tag == '青藏特产';
      if (categoryId == 'hot') return p.salesCount != null && p.salesCount! > 1000;
      return true;
    }).toList();
  }
}
