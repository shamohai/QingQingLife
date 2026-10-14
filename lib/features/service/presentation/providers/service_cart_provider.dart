import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/money.dart';

class ServiceCartItem {
  final String id;
  final String imageUrl;
  final String name;
  final int priceCents;
  final int quantity;
  final bool selected;

  const ServiceCartItem({required this.id, required this.imageUrl, required this.name, required this.priceCents, this.quantity = 1, this.selected = true});

  ServiceCartItem copyWith({bool? selected, int? quantity}) {
    return ServiceCartItem(
      id: id,
      imageUrl: imageUrl,
      name: name,
      priceCents: priceCents,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
    );
  }
}

class ServiceCartState {
  final List<ServiceCartItem> items;
  final String? couponCode;

  const ServiceCartState({required this.items, this.couponCode});

  bool get allSelected => items.isNotEmpty && items.every((item) => item.selected);
  List<ServiceCartItem> get selectedItems => items.where((item) => item.selected).toList();
  int get selectedTotalCents => selectedItems.fold(0, (sum, item) => sum + item.priceCents * item.quantity);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  ServiceCartState copyWith({List<ServiceCartItem>? items, String? couponCode}) {
    return ServiceCartState(items: items ?? this.items, couponCode: couponCode ?? this.couponCode);
  }
}

final serviceCartDataProvider = NotifierProvider<ServiceCartDataProvider, ServiceCartState>(ServiceCartDataProvider.new);

class ServiceCartDataProvider extends Notifier<ServiceCartState> {
  @override
  ServiceCartState build() {
    return const ServiceCartState(
      items: [
        ServiceCartItem(id: 'c1', imageUrl: 'assets/images/product/product1.jpg', name: '天佑德青稞酒 海拔2900 46度500ml', priceCents: 13990),
        ServiceCartItem(id: 'c2', imageUrl: 'assets/images/product/product3.jpg', name: '青海藏牛肉干 原味 100g', priceCents: 5800, quantity: 2),
        ServiceCartItem(id: 'c3', imageUrl: 'assets/images/product/product4.jpg', name: '有机菜籽油 非转基因 5L', priceCents: 7900),
        ServiceCartItem(id: 'c4', imageUrl: 'assets/images/product/product5.jpg', name: '高原枸杞 特级 250g', priceCents: 6800),
      ],
    );
  }

  void toggleSelect(String id) {
    state = state.copyWith(items: state.items.map((item) => item.id == id ? item.copyWith(selected: !item.selected) : item).toList());
  }

  void toggleAll(bool? value) {
    if (value == null) return;
    state = state.copyWith(items: state.items.map((item) => item.copyWith(selected: value)).toList());
  }

  void updateQuantity(String id, int quantity) {
    if (quantity < 1) return;
    state = state.copyWith(items: state.items.map((item) => item.id == id ? item.copyWith(quantity: quantity) : item).toList());
  }

  void removeItem(String id) {
    state = state.copyWith(items: state.items.where((item) => item.id != id).toList());
  }

  void clearAll() {
    state = const ServiceCartState(items: []);
  }
}

/// 购酒享服务结算页专用数据 Provider
///
/// 一期使用静态 mock 数据，后续对接真实 API 时替换为 Repository 调用。
/// 购物车数据由本 feature 自己管理，此处仅管理"继续加购"商品列表与地址文案。

// ── 继续加购商品数据类 ────────────────────────────────────────────────────

class ContinueAddProduct {
  final String id;
  final String imageUrl;
  final String name;
  final int priceCents;

  const ContinueAddProduct({required this.id, required this.imageUrl, required this.name, required this.priceCents});
}

// ── Mock 数据 ──────────────────────────────────────────────────────────────

const _mockContinueAddItems = <ContinueAddProduct>[
  ContinueAddProduct(id: 'ca1', imageUrl: 'assets/images/service/ecommerce1.jpg', name: '天佑德电商专供青稞酒特别版本42度500ml', priceCents: 80000),
  ContinueAddProduct(id: 'ca2', imageUrl: 'assets/images/service/ecommerce2.jpg', name: '天佑德电商专供青稞酒特别版本42度500ml', priceCents: 80000),
  ContinueAddProduct(id: 'ca3', imageUrl: 'assets/images/service/ecommerce3.jpg', name: '天佑德电商专供青稞酒特别版本42度500ml', priceCents: 80000),
];

const _mockAddressText = '请选择配送地址';

// ── Provider ───────────────────────────────────────────────────────────────

/// 继续加购商品列表（静态 mock）
final continueAddItemsProvider = Provider<List<ContinueAddProduct>>((ref) => _mockContinueAddItems);

/// 配送地址文案（静态 mock）
final addressTextProvider = Provider<String>((ref) => _mockAddressText);

/// 当前选中商品的总价。
final selectedTotalProvider = Provider<Money>((ref) {
  final state = ref.watch(serviceCartDataProvider);
  return Money.fromCents(state.selectedTotalCents);
});
