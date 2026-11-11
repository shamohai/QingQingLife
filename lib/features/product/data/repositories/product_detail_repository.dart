import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/product_datasource.dart';
import '../../domain/repositories/product_detail_content_repository.dart';

export '../datasources/product_datasource.dart';

class ProductDetailRepository extends ProductDataSource implements ProductDetailContentRepository {
  ProductDetailRepository();
}

final productDetailRepositoryProvider = Provider<ProductDetailContentRepository>((ref) {
  return ProductDetailRepository();
});
