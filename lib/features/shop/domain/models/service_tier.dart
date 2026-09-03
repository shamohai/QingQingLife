import 'package:flutter/material.dart';

// ─── Service Tier（服务档位，用于购酒享服务/青藏特色） ───

class ServiceTier {
  final String id;
  final String title;
  final String description;
  final int minSpendCents;
  final String? imageUrl;

  const ServiceTier({
    required this.id,
    required this.title,
    required this.description,
    required this.minSpendCents,
    this.imageUrl,
  });

  String get spendFormatted => (minSpendCents / 100).toStringAsFixed(2);
}

// ─── 商品列表项（用于电商特供） ───

class ShopProductItem {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String? tag; // e.g. "自营"

  const ShopProductItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.tag,
  });
}

// ─── 电商特供子分类（左侧边栏） ───

class ShopSubCategory {
  final String id;
  final String label;

  const ShopSubCategory({required this.id, required this.label});

  static const List<ShopSubCategory> mockData = [
    ShopSubCategory(id: 'baijiu', label: '白酒'),
    ShopSubCategory(id: 'redwine', label: '红酒'),
    ShopSubCategory(id: 'whisky', label: '威士忌'),
  ];
}

// ─── 电商特供 Mock 商品数据 ───

class ShopProductMockData {
  static const List<ShopProductItem> products = [
    ShopProductItem(
      id: 'p1', imageUrl: 'assets/images/service/ecommerce1.jpg',
      name: '天佑德电商专供海拔系列\n2900青稞酒46度500ml',
      price: 139.9,
      tag: '自营',
    ),
    ShopProductItem(
      id: 'p2', imageUrl: 'assets/images/service/ecommerce2.jpg',
      name: '天佑德电商专供海拔系列\n2900青稞酒46度500ml',
      price: 139.9,
      tag: '自营',
    ),
    ShopProductItem(
      id: 'p3', imageUrl: 'assets/images/service/ecommerce3.jpg',
      name: '天佑德电商专供海拔系列\n2900青稞酒46度500ml',
      price: 139.9,
      tag: '自营',
    ),
    ShopProductItem(
      id: 'p4', imageUrl: 'assets/images/service/ecommerce4.jpg',
      name: '天佑德电商专供海拔系列\n2900青稞酒46度500ml',
      price: 139.9,
      tag: '自营',
    ),
    ShopProductItem(
      id: 'p5', imageUrl: 'assets/images/service/ecommerce5.jpg',
      name: '天佑德电商专供海拔系列\n2900青稞酒46度500ml',
      price: 139.9,
      tag: '自营',
    ),
  ];
}

// ─── 分类聚合模型 ───

class ServiceCategory {
  final String id;
  final String label;
  final IconData icon;

  // 电商特供：使用商品列表；其他：使用服务档位
  final bool isProductList;
  final List<ServiceTier>? serviceTiers;
  final List<ShopProductItem>? products;
  final List<ShopSubCategory>? subCategories;

  const ServiceCategory({
    required this.id,
    required this.label,
    required this.icon,
    this.isProductList = false,
    this.serviceTiers,
    this.products,
    this.subCategories,
  });

  static const List<ServiceCategory> mockData = [
    ServiceCategory(
      id: 'wine',
      label: '购酒享服务',
      icon: Icons.local_bar_outlined,
      serviceTiers: [
        ServiceTier(id: 'w1', title: '服务一', description: '金牌服务：酒店住宿+接送机+旅游沿线餐饮券', minSpendCents: 100000, imageUrl: 'assets/images/service/tier_wine1.jpg'),
        ServiceTier(id: 'w2', title: '服务二', description: '金牌服务：酒店住宿+接送机+旅游沿线餐饮券', minSpendCents: 200000, imageUrl: 'assets/images/service/tier_wine2.jpg'),
        ServiceTier(id: 'w3', title: '服务三', description: '金牌服务：酒店住宿+接送机+旅游沿线餐饮券', minSpendCents: 300000, imageUrl: 'assets/images/service/tier_wine3.jpg'),
        ServiceTier(id: 'w4', title: '服务四', description: '金牌服务：酒店住宿+接送机+旅游沿线餐饮券', minSpendCents: 400000, imageUrl: 'assets/images/service/tier_wine4.jpg'),
      ],
    ),
    ServiceCategory(
      id: 'region',
      label: '青藏特色',
      icon: Icons.nature_outlined,
      serviceTiers: [
        ServiceTier(id: 'r1', title: '服务一', description: '青藏特产专属配送+定制礼盒包装', minSpendCents: 50000, imageUrl: 'assets/images/service/tier_region1.jpg'),
        ServiceTier(id: 'r2', title: '服务二', description: '青藏特产专属配送+定制礼盒包装+产地溯源证书', minSpendCents: 100000, imageUrl: 'assets/images/service/tier_region2.jpg'),
        ServiceTier(id: 'r3', title: '服务三', description: '青藏特产专属配送+定制礼盒包装+产地溯源证书+VIP客服', minSpendCents: 200000, imageUrl: 'assets/images/service/tier_region3.jpg'),
      ],
    ),
    ServiceCategory(
      id: 'ecommerce',
      label: '电商特供',
      icon: Icons.shopping_bag_outlined,
      isProductList: true,
      subCategories: ShopSubCategory.mockData,
      products: ShopProductMockData.products,
    ),
    ServiceCategory(
      id: 'dingxiang',
      label: '丁香香油',
      icon: Icons.eco,
      serviceTiers: [
        ServiceTier(id: 'd1', title: '服务一', description: '丁香香油单品特惠+新客礼包', minSpendCents: 30000, imageUrl: 'assets/images/service/tier_dingxiang1.jpg'),
        ServiceTier(id: 'd2', title: '服务二', description: '丁香香油组合装特惠+赠品', minSpendCents: 60000, imageUrl: 'assets/images/service/tier_dingxiang2.jpg'),
      ],
    ),
  ];
}
