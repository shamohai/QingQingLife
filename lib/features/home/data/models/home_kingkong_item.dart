import 'package:json_annotation/json_annotation.dart';

part 'home_kingkong_item.g.dart';

@JsonSerializable()
class HomeKingKongItem {
  final String iconUrl;
  final String label;
  final String? actionUrl;

  const HomeKingKongItem({
    required this.iconUrl,
    required this.label,
    this.actionUrl,
  });

  factory HomeKingKongItem.fromJson(Map<String, dynamic> json) =>
      _$HomeKingKongItemFromJson(json);

  Map<String, dynamic> toJson() => _$HomeKingKongItemToJson(this);
}
