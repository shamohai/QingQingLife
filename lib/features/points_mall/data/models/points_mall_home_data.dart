import 'package:json_annotation/json_annotation.dart';

part 'points_mall_home_data.g.dart';

/// 积分商城首页聚合数据模型
@JsonSerializable()
class PointsMallHomeData {
  final String bannerUrl;
  final int currentPoints;
  final int expiringPoints;
  final DateTime expiryDate;
  final String rulesText;
  final List<PointsCategory> categories;
  final List<PointsProduct> recommendedProducts;

  const PointsMallHomeData({
    required this.bannerUrl,
    required this.currentPoints,
    required this.expiringPoints,
    required this.expiryDate,
    required this.rulesText,
    required this.categories,
    required this.recommendedProducts,
  });

  factory PointsMallHomeData.fromJson(Map<String, dynamic> json) => _$PointsMallHomeDataFromJson(json);

  Map<String, dynamic> toJson() => _$PointsMallHomeDataToJson(this);
}

/// 积分商城分类模型
@JsonSerializable()
class PointsCategory {
  final String id;
  final String label;
  final String iconUrl;

  const PointsCategory({required this.id, required this.label, required this.iconUrl});

  factory PointsCategory.fromJson(Map<String, dynamic> json) => _$PointsCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$PointsCategoryToJson(this);
}

/// 积分商品模型
@JsonSerializable()
class PointsProduct {
  final String id;
  final String imageUrl;
  final String name;
  final int points;
  final int? originalPoints;
  final int stock;
  final int salesCount;
  final String? tag;
  final PointsProductType type;

  const PointsProduct({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.points,
    this.originalPoints,
    required this.stock,
    required this.salesCount,
    this.tag,
    required this.type,
  });

  factory PointsProduct.fromJson(Map<String, dynamic> json) => _$PointsProductFromJson(json);

  Map<String, dynamic> toJson() => _$PointsProductToJson(this);
}

/// 积分商品类型枚举
enum PointsProductType { physical, virtual, service }
