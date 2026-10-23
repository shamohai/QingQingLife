import 'package:json_annotation/json_annotation.dart';
import 'carousel_model.dart';

part 'home_kingkong_item.g.dart';

@JsonSerializable()
class HomeKingKongItem {
  final String iconUrl;
  final String label;
  final String? actionUrl;
  @JsonKey(fromJson: _jumpTypeFromJson, toJson: _jumpTypeToJson)
  final JumpType jumpType;

  const HomeKingKongItem({
    required this.iconUrl,
    required this.label,
    this.actionUrl,
    this.jumpType = JumpType.none,
  });

  factory HomeKingKongItem.fromJson(Map<String, dynamic> json) =>
      _$HomeKingKongItemFromJson(json);

  Map<String, dynamic> toJson() => _$HomeKingKongItemToJson(this);

  static JumpType _jumpTypeFromJson(dynamic json) => JumpType.fromJson(json);
  static int _jumpTypeToJson(JumpType type) => type.value;
}
