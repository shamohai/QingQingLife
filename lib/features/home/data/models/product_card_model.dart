import 'package:json_annotation/json_annotation.dart';

part 'product_card_model.g.dart';

@JsonSerializable()
class ProductCardModel {
  final String id;
  final String imageUrl;
  final String name;
  final int priceCents;
  final int? originalPriceCents;
  final String? tag;
  final int? salesCount;

  const ProductCardModel({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.priceCents,
    this.originalPriceCents,
    this.tag,
    this.salesCount,
  });

  factory ProductCardModel.fromJson(Map<String, dynamic> json) =>
      _$ProductCardModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductCardModelToJson(this);
}
