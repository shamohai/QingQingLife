import '../repositories/product_repository.dart';

class ProductDetailContent {
  final ProductDetail product;
  final int memberPriceCents;
  final String salesLabel;
  final int reviewCount;
  final List<ProductReview> reviews;
  final String detailImage;

  const ProductDetailContent({
    required this.product,
    required this.memberPriceCents,
    required this.salesLabel,
    required this.reviewCount,
    required this.reviews,
    required this.detailImage,
  });
}

class ProductReview {
  final String name;
  final String avatar;
  final int rating;
  final String timeLabel;
  final String content;
  final String photos;
  final double photosWidth;

  const ProductReview({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.timeLabel,
    required this.content,
    required this.photos,
    required this.photosWidth,
  });
}
