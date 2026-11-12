import 'package:json_annotation/json_annotation.dart';

part 'points_mall_home_data.g.dart';

@JsonSerializable()
class PointsProduct {
  final String id;
  final String imageUrl;
  final String name;
  final int points;
  final int? originalPoints;
  final int? stock;
  final int? salesCount;
  final int? commentCount;
  final String? tag;
  final PointsProductType type;

  const PointsProduct({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.points,
    this.originalPoints,
    this.stock,
    this.salesCount,
    this.commentCount,
    this.tag,
    required this.type,
  });

  factory PointsProduct.fromJson(Map<String, dynamic> json) => _$PointsProductFromJson(json);

  Map<String, dynamic> toJson() => _$PointsProductToJson(this);
}

enum PointsProductType { physical, virtual, service }
