import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/cart_page_models.dart';
import '../../domain/repositories/cart_page_repository.dart';

/// 统一购物车 Repository 实现
///
/// 购物车商品、收货地址与推荐商品需对接真实接口，接口就绪前返回空数据，
/// 页面以空购物车状态展示，不提供假数据。
class CartRepository implements CartPageRepository {
  const CartRepository();

  @override
  CartPageSeedData loadSeedData() {
    return const CartPageSeedData(addresses: [], items: [], recommendations: []);
  }
}

final cartPageRepositoryProvider = Provider<CartPageRepository>((ref) {
  return const CartRepository();
});

final cartRepositoryProvider = cartPageRepositoryProvider;
