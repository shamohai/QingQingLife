import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/money.dart';
import '../../../../cart/presentation/providers/cart_provider.dart';

/// 购酒享服务结算页专用数据 Provider
///
/// 一期使用静态 mock 数据，后续对接真实 API 时替换为 Repository 调用。
/// 购物车数据共享 [cartDataProvider]，此处仅管理"继续加购"商品列表与地址文案。

// ── 继续加购商品数据类 ────────────────────────────────────────────────────

class ContinueAddProduct {
  final String id;
  final String imageUrl;
  final String name;
  final int priceCents;

  const ContinueAddProduct({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.priceCents,
  });
}

// ── Mock 数据 ──────────────────────────────────────────────────────────────

const _mockContinueAddItems = <ContinueAddProduct>[
  ContinueAddProduct(
    id: 'ca1',
    imageUrl: 'assets/images/service/ecommerce1.jpg',
    name: '天佑德电商专供青稞酒特别版本42度500ml',
    priceCents: 80000,
  ),
  ContinueAddProduct(
    id: 'ca2',
    imageUrl: 'assets/images/service/ecommerce2.jpg',
    name: '天佑德电商专供青稞酒特别版本42度500ml',
    priceCents: 80000,
  ),
  ContinueAddProduct(
    id: 'ca3',
    imageUrl: 'assets/images/service/ecommerce3.jpg',
    name: '天佑德电商专供青稞酒特别版本42度500ml',
    priceCents: 80000,
  ),
];

const _mockAddressText = '请选择配送地址';

// ── Provider ───────────────────────────────────────────────────────────────

/// 继续加购商品列表（静态 mock）
final continueAddItemsProvider = Provider<List<ContinueAddProduct>>((ref) => _mockContinueAddItems);

/// 配送地址文案（静态 mock）
final addressTextProvider = Provider<String>((ref) => _mockAddressText);

/// 当前选中商品的总价（复用 cartDataProvider）
final selectedTotalProvider = Provider<Money>((ref) {
  final state = ref.watch(cartDataProvider);
  return Money.fromCents(state.selectedTotalCents);
});
