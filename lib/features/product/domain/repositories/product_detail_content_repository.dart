import '../models/product_detail_content.dart';

abstract interface class ProductDetailContentRepository {
  Future<ProductDetailContent?> getDetail(String id);
}
