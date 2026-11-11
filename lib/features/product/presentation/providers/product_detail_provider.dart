import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/product_detail_repository.dart';
import '../../domain/models/product_detail_content.dart';

final productDetailProvider = FutureProvider.autoDispose.family<ProductDetailContent?, String>(
  (ref, id) => ref.watch(productDetailRepositoryProvider).getDetail(id),
);
