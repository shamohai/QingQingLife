import 'package:json_annotation/json_annotation.dart';

part 'points_mall_home_data.g.dart';

@JsonSerializable()
class PointsMallHomeData {
  final String bannerUrl;
  final List<String> bannerUrls;
  final int currentPoints;
  final int expiringPoints;
  final DateTime expiryDate;
  final String rulesText;
  final List<PointsCategory> categories;
  final List<PointsProduct> hotProducts;
  final List<PointsRedeemGroup> redeemableGroups;

  const PointsMallHomeData({
    required this.bannerUrl,
    required this.bannerUrls,
    required this.currentPoints,
    required this.expiringPoints,
    required this.expiryDate,
    required this.rulesText,
    required this.categories,
    required this.hotProducts,
    required this.redeemableGroups,
  });

  factory PointsMallHomeData.fromJson(Map<String, dynamic> json) => _$PointsMallHomeDataFromJson(json);

  Map<String, dynamic> toJson() => _$PointsMallHomeDataToJson(this);
}

@JsonSerializable()
class PointsCategory {
  final String id;
  final String label;
  final String iconUrl;

  const PointsCategory({required this.id, required this.label, required this.iconUrl});

  factory PointsCategory.fromJson(Map<String, dynamic> json) => _$PointsCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$PointsCategoryToJson(this);
}

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

enum PointsProductType { physical, virtual, service }

@JsonSerializable()
class PointsRedeemGroup {
  final String rangeLabel;
  final List<PointsProduct> products;

  const PointsRedeemGroup({required this.rangeLabel, required this.products});

  factory PointsRedeemGroup.fromJson(Map<String, dynamic> json) => _$PointsRedeemGroupFromJson(json);

  Map<String, dynamic> toJson() => _$PointsRedeemGroupToJson(this);
}