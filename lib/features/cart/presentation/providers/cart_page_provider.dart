import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/cart_repository.dart';
import '../../domain/models/cart_page_models.dart';

class CartPageState {
  const CartPageState({required this.addresses, required this.selectedAddress, required this.items, required this.recommendations, this.isManaging = false});

  static const int savingPerUnitCents = 1000;

  final List<String> addresses;
  final String selectedAddress;
  final List<CartDisplayItem> items;
  final List<CartRecommendation> recommendations;
  final bool isManaging;

  bool get allSelected => items.isNotEmpty && items.every((item) => item.selected);
  bool get hasSelectedItems => items.any((item) => item.selected);

  int get selectedQuantity => items.where((item) => item.selected).fold(0, (sum, item) => sum + item.quantity);

  int get selectedSubtotalCents => items.where((item) => item.selected).fold(0, (sum, item) => sum + item.priceCents * item.quantity);

  int get selectedSavingsCents => selectedQuantity * savingPerUnitCents;

  int get selectedPayableCents {
    final payable = selectedSubtotalCents - selectedSavingsCents;
    return payable < 0 ? 0 : payable;
  }

  CartPageState copyWith({
    List<String>? addresses,
    String? selectedAddress,
    List<CartDisplayItem>? items,
    List<CartRecommendation>? recommendations,
    bool? isManaging,
  }) {
    return CartPageState(
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      items: items ?? this.items,
      recommendations: recommendations ?? this.recommendations,
      isManaging: isManaging ?? this.isManaging,
    );
  }
}

final cartPageProvider = NotifierProvider<CartPageController, CartPageState>(CartPageController.new);

class CartPageController extends Notifier<CartPageState> {
  @override
  CartPageState build() {
    final seed = ref.read(cartPageRepositoryProvider).loadSeedData();
    return CartPageState(
      addresses: seed.addresses,
      selectedAddress: seed.addresses.isEmpty ? '' : seed.addresses.first,
      items: seed.items,
      recommendations: seed.recommendations,
    );
  }

  void toggleItem(String id) {
    state = state.copyWith(items: state.items.map((item) => item.id == id ? item.copyWith(selected: !item.selected) : item).toList(growable: false));
  }

  void toggleAll(bool selected) {
    state = state.copyWith(items: state.items.map((item) => item.copyWith(selected: selected)).toList(growable: false));
  }

  void updateQuantity(String id, int quantity) {
    final safeQuantity = quantity.clamp(1, 99);
    state = state.copyWith(items: state.items.map((item) => item.id == id ? item.copyWith(quantity: safeQuantity) : item).toList(growable: false));
  }

  void setAddress(String address) {
    if (!state.addresses.contains(address)) return;
    state = state.copyWith(selectedAddress: address);
  }

  void toggleManaging() {
    state = state.copyWith(isManaging: !state.isManaging);
  }

  void deleteSelected() {
    state = state.copyWith(items: state.items.where((item) => !item.selected).toList(growable: false), isManaging: false);
  }

  void deleteItem(String id) {
    state = state.copyWith(items: state.items.where((item) => item.id != id).toList(growable: false));
  }

  void clearAll() {
    state = state.copyWith(items: const [], isManaging: false);
  }

  void addRecommendation(CartRecommendation recommendation) {
    final existingIndex = state.items.indexWhere((item) => item.name == recommendation.name);

    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      updateQuantity(existing.id, existing.quantity + 1);
      return;
    }

    state = state.copyWith(
      items: [
        ...state.items,
        CartDisplayItem(
          id: 'recommendation-cart-${recommendation.id}',
          imageUrl: recommendation.imageUrl,
          name: recommendation.name,
          priceCents: recommendation.priceCents,
          quantity: 1,
          selected: true,
          volumeLabel: recommendation.volumeLabel,
          flavorLabel: recommendation.flavorLabel,
        ),
      ],
    );
  }
}
