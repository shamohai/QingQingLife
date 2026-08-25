// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductCardModel _$ProductCardModelFromJson(Map<String, dynamic> json) =>
    ProductCardModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      name: json['name'] as String,
      priceCents: (json['priceCents'] as num).toInt(),
      originalPriceCents: (json['originalPriceCents'] as num?)?.toInt(),
      tag: json['tag'] as String?,
      salesCount: (json['salesCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductCardModelToJson(ProductCardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'name': instance.name,
      'priceCents': instance.priceCents,
      'originalPriceCents': instance.originalPriceCents,
      'tag': instance.tag,
      'salesCount': instance.salesCount,
    };
