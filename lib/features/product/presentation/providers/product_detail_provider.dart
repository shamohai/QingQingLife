import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/product_detail_mock_repository.dart';
import '../../domain/models/product_detail_content.dart';
import '../../domain/repositories/product_detail_content_repository.dart';

final productDetailRepositoryProvider = Provider<ProductDetailContentRepository>((ref) => const ProductDetailMockRepository());
final productDetailProvider = FutureProvider.autoDispose.family<ProductDetailContent?, String>(
  (ref, id) => ref.watch(productDetailRepositoryProvider).getDetail(id),
);
