// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointsProduct _$PointsProductFromJson(Map<String, dynamic> json) => PointsProduct(
  id: json['id'] as String,
  imageUrl: json['imageUrl'] as String,
  name: json['name'] as String,
  points: (json['points'] as num).toInt(),
  originalPoints: (json['originalPoints'] as num?)?.toInt(),
  stock: (json['stock'] as num?)?.toInt(),
  salesCount: (json['salesCount'] as num?)?.toInt(),
  commentCount: (json['commentCount'] as num?)?.toInt(),
  tag: json['tag'] as String?,
  type: $enumDecode(_$PointsProductTypeEnumMap, json['type']),
);

Map<String, dynamic> _$PointsProductToJson(PointsProduct instance) => <String, dynamic>{
  'id': instance.id,
  'imageUrl': instance.imageUrl,
  'name': instance.name,
  'points': instance.points,
  'originalPoints': instance.originalPoints,
  'stock': instance.stock,
  'salesCount': instance.salesCount,
  'commentCount': instance.commentCount,
  'tag': instance.tag,
  'type': _$PointsProductTypeEnumMap[instance.type]!,
};

const _$PointsProductTypeEnumMap = {PointsProductType.physical: 'physical', PointsProductType.virtual: 'virtual', PointsProductType.service: 'service'};
