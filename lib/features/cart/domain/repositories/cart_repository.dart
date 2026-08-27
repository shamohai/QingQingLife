import '../../../../core/network/api_response.dart';

/// 购物车仓库接口
abstract class CartRepository {
  /// 获取购物车列表
  Future<ApiResponse<CartData>> getCart();

  /// 添加商品到购物车
  Future<ApiResponse<CartItem>> addToCart({required String productId, required String skuId, required int quantity});

  /// 更新购物车商品数量
  Future<ApiResponse<CartItem>> updateQuantity({required String cartItemId, required int quantity});

  /// 删除购物车商品
  Future<ApiResponse<void>> removeFromCart(String cartItemId);

  /// 批量删除
  Future<ApiResponse<void>> batchRemove(List<String> cartItemIds);

  /// 全选/取消全选
  Future<ApiResponse<void>> selectAll(bool selected);

  /// 单选/取消单选
  Future<ApiResponse<void>> selectItem(String cartItemId, bool selected);

  /// 清空购物车
  Future<ApiResponse<void>> clearCart();

  /// 获取购物车商品总数（用于 Badge）
  Future<ApiResponse<int>> getCartCount();
}

/// 购物车聚合数据
class CartData {
  final List<CartStore> stores;
  final int totalQuantity;
  final int totalPriceCents;
  final int selectedQuantity;
  final int selectedPriceCents;
  final bool allSelected;

  const CartData({
    required this.stores,
    required this.totalQuantity,
    required this.totalPriceCents,
    required this.selectedQuantity,
    required this.selectedPriceCents,
    required this.allSelected,
  });
}

/// 购物车店铺分组
class CartStore {
  final String storeId;
  final String storeName;
  final List<CartItem> items;
  final bool selected;

  const CartStore({required this.storeId, required this.storeName, required this.items, required this.selected});
}

/// 购物车商品项
class CartItem {
  final String id;
  final String productId;
  final String skuId;
  final String productName;
  final String skuName;
  final String imageUrl;
  final int priceCents;
  final int originalPriceCents;
  int quantity;
  final int stock;
  bool selected;
  final String? tag;

  CartItem({
    required this.id,
    required this.productId,
    required this.skuId,
    required this.productName,
    required this.skuName,
    required this.imageUrl,
    required this.priceCents,
    required this.originalPriceCents,
    required this.quantity,
    required this.stock,
    required this.selected,
    this.tag,
  });

  int get totalPriceCents => priceCents * quantity;
}
