import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/money.dart';
import '../../domain/models/share_cart_candidate_model.dart';
import '../../domain/models/share_cart_product_model.dart';
import '../../data/datasources/service_remote_datasource.dart';

/// 购酒享服务购物车页面专用状态
///
/// 按 templateId + cartId 实例化，管理三步 API 调用结果：
/// 1. createShareCart         -> shareCartId
/// 2. getShareCartProductList  -> ShareCartProductList
/// 3. getCandidateProductList  -> CandidateProductList
class ServiceCartState {
  /// 有效的 shareCartId（0 表示尚未创建）
  final int shareCartId;

  /// 购物车中的商品列表
  final List<ShareCartProduct> cartProducts;

  /// 是否允许提交订单
  final bool canSubmit;

  /// 不允许提交时的原因
  final String verifyMsg;

  /// 继续加购候选商品列表
  final List<CandidateProduct> candidateProducts;

  /// 候选商品是否还有更多页
  final bool hasMoreCandidates;

  /// 本地选中状态：pid -> selected
  final Map<int, bool> selectedMap;
  final bool? isUpdatingCart;

  bool get cartUpdateInProgress => isUpdatingCart == true;

  const ServiceCartState({
    required this.shareCartId,
    this.cartProducts = const [],
    this.canSubmit = true,
    this.verifyMsg = '',
    this.candidateProducts = const [],
    this.hasMoreCandidates = false,
    this.selectedMap = const {},
    this.isUpdatingCart = false,
  });

  /// 当前选中的商品列表
  List<ShareCartProduct> get selectedProducts {
    return cartProducts.where((p) => selectedMap[p.pid] ?? true).toList();
  }

  /// 是否全选
  bool get allSelected {
    if (cartProducts.isEmpty) return false;
    return cartProducts.every((p) => selectedMap[p.pid] ?? true);
  }

  /// 选中商品合计金额（分）
  int get selectedTotalCents {
    return selectedProducts.fold(0, (sum, p) => sum + (p.price * 100).round() * p.count);
  }

  /// 格式化后的选中合计金额字符串
  String get selectedTotalFormatted {
    return Money.fromCents(selectedTotalCents).format();
  }

  ServiceCartState copyWith({
    int? shareCartId,
    List<ShareCartProduct>? cartProducts,
    bool? canSubmit,
    String? verifyMsg,
    List<CandidateProduct>? candidateProducts,
    bool? hasMoreCandidates,
    Map<int, bool>? selectedMap,
    bool? isUpdatingCart,
  }) {
    return ServiceCartState(
      shareCartId: shareCartId ?? this.shareCartId,
      cartProducts: cartProducts ?? this.cartProducts,
      canSubmit: canSubmit ?? this.canSubmit,
      verifyMsg: verifyMsg ?? this.verifyMsg,
      candidateProducts: candidateProducts ?? this.candidateProducts,
      hasMoreCandidates: hasMoreCandidates ?? this.hasMoreCandidates,
      selectedMap: selectedMap ?? this.selectedMap,
      isUpdatingCart: isUpdatingCart ?? cartUpdateInProgress,
    );
  }
}

/// 初始化参数，由路由传入
class ServiceCartInitialParams {
  final int templateId;
  final String headImg;

  /// 0 表示购物车尚未创建，需要调用 createShareCart
  final int existingCartId;

  const ServiceCartInitialParams({required this.templateId, required this.headImg, this.existingCartId = 0});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ServiceCartInitialParams && other.templateId == templateId && other.headImg == headImg && other.existingCartId == existingCartId;
  }

  @override
  int get hashCode => Object.hash(templateId, headImg, existingCartId);
}

/// 服务购物车 Provider（family，按参数对象隔离）
///
/// 路由进入方式：/service/cart?templateId=xxx&headImg=xxx&cartId=xxx
/// cartId == 0 时先调用 createShareCart 获取 shareCartId，再拉取商品列表。
final serviceCartProvider = AsyncNotifierProvider.family<ServiceCartNotifier, ServiceCartState, ServiceCartInitialParams>(ServiceCartNotifier.new);

class ServiceCartNotifier extends AsyncNotifier<ServiceCartState> {
  final ServiceCartInitialParams _params;
  int? _createdShareCartId;

  ServiceCartNotifier(this._params);

  @override
  Future<ServiceCartState> build() async {
    return _load();
  }

  Future<ServiceCartState> _load() async {
    final ds = ref.read(serviceRemoteDataSourceProvider);

    // Step 1: 确定 shareCartId
    final shareCartId = _createdShareCartId ?? _params.existingCartId;
    if (shareCartId > 0) {
      _createdShareCartId = shareCartId;
    } else {
      final createResp = await ds.createShareCart(_params.templateId);
      _createdShareCartId = createResp.requireData;
    }

    final effectiveShareCartId = _createdShareCartId!;
    final productListFuture = ds.getShareCartProductList(effectiveShareCartId);
    final candidateListFuture = ds.getCandidateProductList(effectiveShareCartId, 1, 20);
    final productList = (await productListFuture).requireData;
    final candidateList = (await candidateListFuture).requireData;

    // 构建 selectedMap（默认全部选中）
    final selectedMap = <int, bool>{for (final p in productList.list) p.pid: true};

    return ServiceCartState(
      shareCartId: effectiveShareCartId,
      cartProducts: productList.list,
      canSubmit: productList.canSubmit,
      verifyMsg: productList.verifyMsg,
      candidateProducts: candidateList.products,
      hasMoreCandidates: candidateList.totalCount > candidateList.products.length,
      selectedMap: selectedMap,
    );
  }

  /// 重试加载时复用已创建的购物车，避免重复创建。
  Future<void> retry() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _load());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  /// 切换单个商品选中状态
  void toggleSelect(int pid) {
    final current = state.value;
    if (current == null) return;
    final newMap = Map<int, bool>.from(current.selectedMap);
    newMap[pid] = !(newMap[pid] ?? true);
    state = AsyncData(current.copyWith(selectedMap: newMap));
  }

  /// 全选 / 取消全选
  void toggleAll(bool value) {
    final current = state.value;
    if (current == null) return;
    final newMap = <int, bool>{for (final p in current.cartProducts) p.pid: value};
    state = AsyncData(current.copyWith(selectedMap: newMap));
  }

  /// 刷新候选商品（分页加载）
  Future<void> loadMoreCandidates() async {
    final current = state.value;
    if (current == null || !current.hasMoreCandidates) return;

    final ds = ref.read(serviceRemoteDataSourceProvider);
    final nextPage = current.candidateProducts.length ~/ 20 + 1;
    final resp = await ds.getCandidateProductList(current.shareCartId, nextPage, 20);
    if (!resp.success) return;

    final newData = resp.requireData;
    state = AsyncData(
      current.copyWith(
        candidateProducts: [...current.candidateProducts, ...newData.products],
        hasMoreCandidates: current.candidateProducts.length + newData.products.length < newData.totalCount,
      ),
    );
  }

  /// 刷新购物车商品（数量变化后重新拉取）
  Future<void> refreshCartProducts() async {
    final current = state.value;
    if (current == null || current.shareCartId == 0) return;

    final ds = ref.read(serviceRemoteDataSourceProvider);
    final resp = await ds.getShareCartProductList(current.shareCartId);
    if (!resp.success) return;

    final productList = resp.requireData;
    // 保留现有 selectedMap 对新商品的默认值
    final selectedMap = <int, bool>{for (final p in productList.list) p.pid: current.selectedMap[p.pid] ?? true};
    state = AsyncData(
      current.copyWith(cartProducts: productList.list, canSubmit: productList.canSubmit, verifyMsg: productList.verifyMsg, selectedMap: selectedMap),
    );
  }

  /// 点击候选商品的加号：首次用默认数量，已在购物车则 +1。
  /// 直接调接口，不再客户端提前 return（避免达到 maxCount 时静默失败）。
  Future<void> addCandidateProduct(CandidateProduct candidate) async {
    final current = state.value;
    if (current == null || current.cartUpdateInProgress) return;
    ShareCartProduct? existingProduct;
    for (final product in current.cartProducts) {
      if (product.pid == candidate.productId) {
        existingProduct = product;
        break;
      }
    }
    final newCount = existingProduct == null
        ? candidate.defaultQuantity.clamp(candidate.minCount, candidate.maxCount).toInt()
        : (existingProduct.count + 1).clamp(candidate.minCount, candidate.maxCount).toInt();
    await addProductToCart(candidate.productId, newCount);
  }

  /// 向服务端写入目标数量，再拉取最新购物车列表更新本地状态。
  Future<void> addProductToCart(int pid, int newCount) async {
    final current = state.value;
    if (current == null || current.shareCartId == 0 || current.cartUpdateInProgress || newCount < 1) return;
    final ds = ref.read(serviceRemoteDataSourceProvider);
    state = AsyncData(current.copyWith(isUpdatingCart: true));
    try {
      final mutationResponse = await ds.addProductToShareCart(current.shareCartId, pid, newCount);
      if (!mutationResponse.success) {
        mutationResponse.requireData;
      }
      final cartResponse = await ds.getShareCartProductList(current.shareCartId);
      final cart = cartResponse.requireData;
      final latest = state.value ?? current;
      final selectedMap = <int, bool>{for (final product in cart.list) product.pid: latest.selectedMap[product.pid] ?? true};
      final cartProductsById = {for (final product in cart.list) product.pid: product};
      final candidateProducts = latest.candidateProducts
          .map((candidate) => candidate.copyWith(cartNum: cartProductsById[candidate.productId]?.count ?? 0))
          .toList();
      state = AsyncData(
        latest.copyWith(
          cartProducts: cart.list,
          candidateProducts: candidateProducts,
          canSubmit: cart.canSubmit,
          verifyMsg: cart.verifyMsg,
          selectedMap: selectedMap,
          isUpdatingCart: false,
        ),
      );
    } finally {
      final latest = state.value ?? current;
      if (latest.cartUpdateInProgress) {
        state = AsyncData(latest.copyWith(isUpdatingCart: false));
      }
    }
  }
}
