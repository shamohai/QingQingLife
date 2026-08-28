// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points_mall_home_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointsMallHomeData _$PointsMallHomeDataFromJson(Map<String, dynamic> json) =>
    PointsMallHomeData(
      bannerUrl: json['bannerUrl'] as String,
      bannerUrls: (json['bannerUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      currentPoints: (json['currentPoints'] as num).toInt(),
      expiringPoints: (json['expiringPoints'] as num).toInt(),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      rulesText: json['rulesText'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => PointsCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      hotProducts: (json['hotProducts'] as List<dynamic>)
          .map((e) => PointsProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      redeemableGroups: (json['redeemableGroups'] as List<dynamic>)
          .map((e) => PointsRedeemGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PointsMallHomeDataToJson(PointsMallHomeData instance) =>
    <String, dynamic>{
      'bannerUrl': instance.bannerUrl,
      'bannerUrls': instance.bannerUrls,
      'currentPoints': instance.currentPoints,
      'expiringPoints': instance.expiringPoints,
      'expiryDate': instance.expiryDate.toIso8601String(),
      'rulesText': instance.rulesText,
      'categories': instance.categories,
      'hotProducts': instance.hotProducts,
      'redeemableGroups': instance.redeemableGroups,
    };

PointsCategory _$PointsCategoryFromJson(Map<String, dynamic> json) =>
    PointsCategory(
      id: json['id'] as String,
      label: json['label'] as String,
      iconUrl: json['iconUrl'] as String,
    );

Map<String, dynamic> _$PointsCategoryToJson(PointsCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'iconUrl': instance.iconUrl,
    };

PointsProduct _$PointsProductFromJson(Map<String, dynamic> json) =>
    PointsProduct(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      name: json['name'] as String,
      points: (json['points'] as num).toInt(),
      originalPoints: (json['originalPoints'] as num?)?.toInt(),
      stock: (json['stock'] as num).toInt(),
      salesCount: (json['salesCount'] as num).toInt(),
      tag: json['tag'] as String?,
      type: $enumDecode(_$PointsProductTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$PointsProductToJson(PointsProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'name': instance.name,
      'points': instance.points,
      'originalPoints': instance.originalPoints,
      'stock': instance.stock,
      'salesCount': instance.salesCount,
      'tag': instance.tag,
      'type': _$PointsProductTypeEnumMap[instance.type]!,
    };

const _$PointsProductTypeEnumMap = {
  PointsProductType.physical: 'physical',
  PointsProductType.virtual: 'virtual',
  PointsProductType.service: 'service',
};

PointsRedeemGroup _$PointsRedeemGroupFromJson(Map<String, dynamic> json) =>
    PointsRedeemGroup(
      rangeLabel: json['rangeLabel'] as String,
      products: (json['products'] as List<dynamic>)
          .map((e) => PointsProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PointsRedeemGroupToJson(PointsRedeemGroup instance) =>
    <String, dynamic>{
      'rangeLabel': instance.rangeLabel,
      'products': instance.products,
    };
