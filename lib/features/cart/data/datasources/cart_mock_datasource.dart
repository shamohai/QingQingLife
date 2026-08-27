import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/cart_repository.dart';
import '../../../../core/network/api_response.dart';

/// Mock 购物车数据源 - 开发/测试环境使用
class MockCartDataSource implements CartRepository {
  // 内存模拟购物车数据
  final List<CartItem> _items = [
    CartItem(
      id: 'ci_1',
      productId: '1',
      skuId: 'sku_1',
      productName: '天佑德电商专供海拔系列 2900青稞酒 46度500ml',
      skuName: '500ml 单瓶',
      imageUrl: 'https://picsum.photos/300/300?random=10',
      priceCents: 13990,
      originalPriceCents: 16800,
      quantity: 2,
      stock: 100,
      selected: true,
      tag: '自营',
    ),
    CartItem(
      id: 'ci_2',
      productId: '3',
      skuId: 'sku_3',
      productName: '青海藏牛肉干 原味 100g',
      skuName: '100g',
      imageUrl: 'https://picsum.photos/300/300?random=12',
      priceCents: 5800,
      originalPriceCents: 5800,
      quantity: 1,
      stock: 50,
      selected: true,
      tag: '青藏特产',
    ),
    CartItem(
      id: 'ci_3',
      productId: '5',
      skuId: 'sku_5',
      productName: '天佑德青稞酒 礼盒装 500ml×2',
      skuName: '500ml×2 礼盒',
      imageUrl: 'https://picsum.photos/300/300?random=14',
      priceCents: 25800,
      originalPriceCents: 29800,
      quantity: 1,
      stock: 20,
      selected: false,
      tag: '特价',
    ),
  ];

  @override
  Future<ApiResponse<CartData>> getCart() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final stores = _groupByStore(_items);
    final totalQuantity = _items.fold(0, (sum, item) => sum + item.quantity);
    final totalPriceCents = _items.fold(0, (sum, item) => sum + item.totalPriceCents);
    final selectedItems = _items.where((i) => i.selected).toList();
    final selectedQuantity = selectedItems.fold(0, (sum, item) => sum + item.quantity);
    final selectedPriceCents = selectedItems.fold(0, (sum, item) => sum + item.totalPriceCents);
    final allSelected = _items.isNotEmpty && _items.every((i) => i.selected);

    return ApiResponse.success(
      CartData(
        stores: stores,
        totalQuantity: totalQuantity,
        totalPriceCents: totalPriceCents,
        selectedQuantity: selectedQuantity,
        selectedPriceCents: selectedPriceCents,
        allSelected: allSelected,
      ),
    );
  }

  List<CartStore> _groupByStore(List<CartItem> items) {
    // 简单按 tag 分组模拟店铺
    final Map<String, List<CartItem>> grouped = {};
    for (final item in items) {
      final key = item.tag ?? '默认店铺';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped.entries
        .map(
          (e) => CartStore(
            storeId: 'store_${e.key.hashCode}',
            storeName: e.key,
            items: e.value,
            selected: e.value.every((i) => i.selected),
          ),
        )
        .toList();
  }

  @override
  Future<ApiResponse<CartItem>> addToCart({
    required String productId,
    required String skuId,
    required int quantity,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 查找是否已存在
    final existingIndex = _items.indexWhere((i) => i.productId == productId && i.skuId == skuId);
    if (existingIndex >= 0) {
      final item = _items[existingIndex];
      item.quantity = (item.quantity + quantity).clamp(1, item.stock);
      return ApiResponse.success(item);
    }

    // 新增 Mock 商品
    final newItem = CartItem(
      id: 'ci_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      skuId: skuId,
      productName: 'Mock 商品 $productId',
      skuName: '默认规格',
      imageUrl: 'https://picsum.photos/300/300?random=$productId',
      priceCents: 9900,
      originalPriceCents: 12000,
      quantity: quantity,
      stock: 100,
      selected: true,
      tag: '自营',
    );
    _items.add(newItem);
    return ApiResponse.success(newItem);
  }

  @override
  Future<ApiResponse<CartItem>> updateQuantity({required String cartItemId, required int quantity}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _items.indexWhere((i) => i.id == cartItemId);
    if (index < 0) {
      return ApiResponse.error('商品不存在');
    }

    final item = _items[index];
    if (quantity <= 0) {
      _items.removeAt(index);
      return ApiResponse.success(item);
    }
    if (quantity > item.stock) {
      return ApiResponse.error('库存不足');
    }
    item.quantity = quantity;
    return ApiResponse.success(item);
  }

  @override
  Future<ApiResponse<void>> removeFromCart(String cartItemId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.removeWhere((i) => i.id == cartItemId);
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> batchRemove(List<String> cartItemIds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.removeWhere((i) => cartItemIds.contains(i.id));
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> selectAll(bool selected) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final item in _items) {
      item.selected = selected;
    }
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> selectItem(String cartItemId, bool selected) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _items.indexWhere((i) => i.id == cartItemId);
    if (index >= 0) {
      _items[index].selected = selected;
    }
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> clearCart() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.clear();
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<int>> getCartCount() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final count = _items.fold(0, (sum, item) => sum + item.quantity);
    return ApiResponse.success(count);
  }
}

/// MockCartRepository Provider - 开发环境使用
final mockCartRepositoryProvider = Provider<CartRepository>((ref) => MockCartDataSource());
