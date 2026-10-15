import '../../domain/models/product_detail_content.dart';
import '../../domain/repositories/product_detail_content_repository.dart';
import '../../domain/repositories/product_repository.dart';

class ProductDetailMockRepository implements ProductDetailContentRepository {
  const ProductDetailMockRepository();

  @override
  Future<ProductDetailContent?> getDetail(String id) async {
    if (int.tryParse(id) == null || int.parse(id) <= 0) return null;
    const asset = 'assets/images/product/';
    return ProductDetailContent(
      product: ProductDetail(
        id: id,
        name: '天佑德电商专供青稞酒特别版本42度500ml',
        description: '独创天酿工艺，天、时、人酒合而为一，历经4个季节，24个节气，4次投粮、16次蒸酒，才得经久美味。',
        images: List<String>.filled(5, '${asset}detail-hero.png', growable: false),
        priceCents: 80000,
        originalPriceCents: 90000,
        skus: const [
          ProductSku(id: '500ml', name: '500ml', priceCents: 80000, stock: 100, attributes: {'容量': '500ml'}),
        ],
        specs: const [
          ProductSpec(key: '酒精度', value: '52%vol'),
          ProductSpec(key: '香型', value: '清香型'),
        ],
      ),
      memberPriceCents: 76000,
      salesLabel: '9万件',
      reviewCount: 74677,
      reviews: const [
        ProductReview(
          name: '道士哥哥',
          avatar: '${asset}detail-review-avatar.png',
          rating: 3,
          timeLabel: '2小时前',
          content: '想着200-800价位的酒都喝遍了 能不能尝尝新鲜的决定了吃羊肉原本想搞一瓶青花30喝喝的结果突然想来青海有天佑德果真不一样清甜甘咧青稞和苹果的香气酒质相当不错。',
          photos: '${asset}detail-review-first-strip.png',
          photosWidth: 232,
        ),
        ProductReview(
          name: '道士哥哥',
          avatar: '${asset}detail-review-avatar.png',
          rating: 3,
          timeLabel: '1天前',
          content: '和舍友一起喝的，舍友都说还不错，另外瓶身设计确实大气上档次:',
          photos: '${asset}detail-review-second-strip.png',
          photosWidth: 151,
        ),
      ],
      detailImage: '${asset}detail-poster.png',
    );
  }
}
