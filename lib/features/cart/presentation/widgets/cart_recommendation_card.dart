import 'package:flutter/material.dart';

import '../../domain/models/cart_page_models.dart';
import 'cart_design_tokens.dart';
import 'cart_product_image.dart';

class CartRecommendationCard extends StatelessWidget {
  const CartRecommendationCard({super.key, required this.product, required this.onAdd});

  final CartRecommendation product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CartDesignTokens.cardRadius),
      child: ColoredBox(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: const CartProductImage(variant: CartProductImageVariant.recommendation, fit: BoxFit.contain),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _RecommendationTitle(product: product)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _NeutralTag(label: product.volumeLabel),
                        const SizedBox(width: 5),
                        _NeutralTag(label: product.flavorLabel),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _RecommendationPrice(cents: product.priceCents),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '¥${(product.originalPriceCents / 100).toStringAsFixed(0)}',
                            style: const TextStyle(color: Color(0xFFACAFB4), fontSize: 12, height: 1),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: onAdd,
                          tooltip: '加入购物车',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(width: 34, height: 34),
                          icon: const Icon(Icons.shopping_cart_rounded, color: CartDesignTokens.price, size: 28),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationTitle extends StatelessWidget {
  const _RecommendationTitle({required this.product});

  final CartRecommendation product;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SizedBox(
              width: 104,
              child: Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: CartDesignTokens.primary, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '会员价:¥${(product.memberPriceCents / 100).toStringAsFixed(0)}',
                  style: const TextStyle(color: CartDesignTokens.memberGold, fontSize: 12, height: 1, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          TextSpan(text: ' ${product.name}'),
        ],
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Color(0xFF111111), fontSize: 16, height: 1.45, fontWeight: FontWeight.w600),
    );
  }
}

class _NeutralTag extends StatelessWidget {
  const _NeutralTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD6D7DA)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFFA4A6AA), fontSize: 12, height: 1, fontWeight: FontWeight.w400),
      ),
    );
  }
}

class _RecommendationPrice extends StatelessWidget {
  const _RecommendationPrice({required this.cents});

  final int cents;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: '¥',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          TextSpan(text: (cents / 100).toStringAsFixed(0)),
        ],
      ),
      maxLines: 1,
      style: const TextStyle(color: CartDesignTokens.price, fontSize: 24, height: 1, fontWeight: FontWeight.w500),
    );
  }
}
