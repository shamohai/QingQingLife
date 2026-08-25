import 'package:json_annotation/json_annotation.dart';

part 'home_new_user_gift.g.dart';

@JsonSerializable()
class HomeNewUserGift {
  final String title;
  final String? desc;
  final String? imageUrl;
  final String? actionUrl;

  const HomeNewUserGift({
    required this.title,
    this.desc,
    this.imageUrl,
    this.actionUrl,
  });

  factory HomeNewUserGift.fromJson(Map<String, dynamic> json) =>
      _$HomeNewUserGiftFromJson(json);

  Map<String, dynamic> toJson() => _$HomeNewUserGiftToJson(this);
}
