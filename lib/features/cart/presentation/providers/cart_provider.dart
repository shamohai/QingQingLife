import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 购物车商品项
class CartItem {
  final String id;
  final String imageUrl;
  final String name;
  final int priceCents;
  final int quantity;
  final bool selected;

  const CartItem({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.priceCents,
    this.quantity = 1,
    this.selected = true,
  });

  CartItem copyWith({bool? selected, int? quantity}) {
    return CartItem(
      id: id,
      imageUrl: imageUrl,
      name: name,
      priceCents: priceCents,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
    );
  }
}

/// 购物车状态
class CartState {
  final List<CartItem> items;
  final String? couponCode;

  const CartState({required this.items, this.couponCode});

  bool get allSelected => items.isNotEmpty && items.every((i) => i.selected);
  List<CartItem> get selectedItems => items.where((i) => i.selected).toList();
  int get selectedTotalCents => selectedItems.fold(0, (sum, i) => sum + i.priceCents * i.quantity);
  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  CartState copyWith({List<CartItem>? items, String? couponCode}) {
    return CartState(items: items ?? this.items, couponCode: couponCode ?? this.couponCode);
  }
}

/// 购物车数据 Provider（使用 Notifier）
final cartDataProvider = NotifierProvider<CartDataProvider, CartState>(() => CartDataProvider());

class CartDataProvider extends Notifier<CartState> {
  @override
  CartState build() {
    return const CartState(items: [
      CartItem(id: 'c1', imageUrl: 'https://loremflickr.com/300/300?random=70', name: '天佑德青稞酒 海拔2900 46度500ml', priceCents: 13990, quantity: 1),
      CartItem(id: 'c2', imageUrl: 'https://loremflickr.com/300/300?random=71', name: '青海藏牛肉干 原味 100g', priceCents: 5800, quantity: 2),
      CartItem(id: 'c3', imageUrl: 'https://loremflickr.com/300/300?random=72', name: '有机菜籽油 非转基因 5L', priceCents: 7900, quantity: 1),
      CartItem(id: 'c4', imageUrl: 'https://loremflickr.com/300/300?random=73', name: '高原枸杞 特级 250g', priceCents: 6800, quantity: 1),
    ]);
  }

  void toggleSelect(String id) {
    state = state.copyWith(items: state.items.map((i) => i.id == id ? i.copyWith(selected: !i.selected) : i).toList());
  }

  void toggleAll(bool? value) {
    if (value == null) return;
    state = state.copyWith(items: state.items.map((i) => i.copyWith(selected: value)).toList());
  }

  void updateQuantity(String id, int quantity) {
    if (quantity < 1) return;
    state = state.copyWith(items: state.items.map((i) => i.id == id ? i.copyWith(quantity: quantity) : i).toList());
  }

  void removeItem(String id) {
    state = state.copyWith(items: state.items.where((i) => i.id != id).toList());
  }

  void clearAll() {
    state = const CartState(items: []);
  }
}
