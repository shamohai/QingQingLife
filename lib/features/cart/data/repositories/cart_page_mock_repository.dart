import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/cart_page_models.dart';
import '../../domain/repositories/cart_page_repository.dart';

const cartLanhuThumbnailUrl = 'https://lanhu-oss-2537-2.lanhuapp.com/FigmaDDSSlicePNG5dc0e9629ac1ccf335ecb422332c0b59.png';
const cartLanhuRecommendationUrl = 'https://lanhu-oss-2537-2.lanhuapp.com/FigmaDDSSlicePNG4da2cc058cd2093f461bfcf5417e8cda.png';

class CartPageMockRepository implements CartPageRepository {
  const CartPageMockRepository();

  static const _productName = '天佑德电商专供青稞酒特别版本42度500ml';

  @override
  CartPageSeedData loadSeedData() {
    return CartPageSeedData(
      addresses: const ['甘肃省兰州市七里河区建兰路街道', '青海省西宁市城西区文汇路街道', '北京市朝阳区望京街道'],
      items: List.generate(
        4,
        (index) =>
            CartDisplayItem(id: 'lanhu-cart-${index + 1}', imageUrl: cartLanhuThumbnailUrl, name: _productName, priceCents: 80000, quantity: 1, selected: true),
        growable: false,
      ),
      recommendations: List.generate(
        4,
        (index) => CartRecommendation(
          id: 'lanhu-recommendation-${index + 1}',
          imageUrl: cartLanhuRecommendationUrl,
          name: _productName,
          priceCents: 80000,
          originalPriceCents: 98500,
          memberPriceCents: 76000,
        ),
        growable: false,
      ),
    );
  }
}

final cartPageRepositoryProvider = Provider<CartPageRepository>((ref) {
  return const CartPageMockRepository();
});
