// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_banner_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeBannerItem _$HomeBannerItemFromJson(Map<String, dynamic> json) =>
    HomeBannerItem(
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String?,
      actionUrl: json['actionUrl'] as String?,
    );

Map<String, dynamic> _$HomeBannerItemToJson(HomeBannerItem instance) =>
    <String, dynamic>{
      'imageUrl': instance.imageUrl,
      'title': instance.title,
      'actionUrl': instance.actionUrl,
    };
