class CartDisplayItem {
  const CartDisplayItem({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.priceCents,
    required this.quantity,
    required this.selected,
    this.volumeLabel = '52%vol',
    this.flavorLabel = '清香型',
  });

  final String id;
  final String imageUrl;
  final String name;
  final int priceCents;
  final int quantity;
  final bool selected;
  final String volumeLabel;
  final String flavorLabel;

  CartDisplayItem copyWith({int? quantity, bool? selected}) {
    return CartDisplayItem(
      id: id,
      imageUrl: imageUrl,
      name: name,
      priceCents: priceCents,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
      volumeLabel: volumeLabel,
      flavorLabel: flavorLabel,
    );
  }
}

class CartRecommendation {
  const CartRecommendation({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.priceCents,
    required this.originalPriceCents,
    required this.memberPriceCents,
    this.volumeLabel = '52%vol',
    this.flavorLabel = '清香型',
  });

  final String id;
  final String imageUrl;
  final String name;
  final int priceCents;
  final int originalPriceCents;
  final int memberPriceCents;
  final String volumeLabel;
  final String flavorLabel;
}

class CartPageSeedData {
  const CartPageSeedData({required this.addresses, required this.items, required this.recommendations});

  final List<String> addresses;
  final List<CartDisplayItem> items;
  final List<CartRecommendation> recommendations;
}
