import 'package:json_annotation/json_annotation.dart';

part 'home_banner_item.g.dart';

@JsonSerializable()
class HomeBannerItem {
  final String imageUrl;
  final String? title;
  final String? actionUrl;

  const HomeBannerItem({
    required this.imageUrl,
    this.title,
    this.actionUrl,
  });

  factory HomeBannerItem.fromJson(Map<String, dynamic> json) =>
      _$HomeBannerItemFromJson(json);

  Map<String, dynamic> toJson() => _$HomeBannerItemToJson(this);
}
