import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/order_list_order.dart';

class AllOrdersState {
  final List<OrderListOrder> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int activeTabIndex;
  final int page;
  final int total;
  final String keyword;

  const AllOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.activeTabIndex = 0,
    this.page = 0,
    this.total = 0,
    this.keyword = '',
  });

  AllOrdersState copyWith({List<OrderListOrder>? orders, bool? isLoading, bool? isLoadingMore, bool? hasMore, int? page, int? total}) => AllOrdersState(
    orders: orders ?? this.orders,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    activeTabIndex: activeTabIndex,
    page: page ?? this.page,
    total: total ?? this.total,
    keyword: keyword,
  );
}

class AllOrdersNotifier extends Notifier<AllOrdersState> {
  static const tabLabels = ['全部订单', '待付款', '待发货', '待收货/待核销', '售后/退款'];
  static const tabStates = [
    BackendOrderState.all,
    BackendOrderState.pendingPayment,
    BackendOrderState.pendingShipment,
    BackendOrderState.shipped,
    BackendOrderState.afterSale,
  ];
  static const pageSize = 20;
  int _requestVersion = 0;
  final _cancellingOrderIds = <String>{};
  final _confirmingOrderIds = <String>{};

  @override
  AllOrdersState build() => const AllOrdersState();

  Future<void> initialize({int tabIndex = 0}) {
    state = AllOrdersState(activeTabIndex: tabIndex);
    return _fetch();
  }

  Future<void> selectTab(int index) {
    if (index < 0 || index >= tabStates.length || index == state.activeTabIndex) return Future.value();
    state = AllOrdersState(activeTabIndex: index, keyword: state.keyword);
    return _fetch();
  }

  Future<void> search(String input) {
    state = AllOrdersState(activeTabIndex: state.activeTabIndex, keyword: input.trim());
    return _fetch();
  }

  Future<void> loadOrders() {
    if (state.isLoading) return Future.value();
    return _fetch();
  }

  Future<void> loadMore() {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return Future.value();
    return _fetch(append: true);
  }

  Future<void> cancelOrder(String orderId) async {
    if (orderId.isEmpty || !_cancellingOrderIds.add(orderId)) return;
    try {
      final response = await ref.read(orderRepositoryProvider).cancelOrder(orderId, '');
      if (!response.success) {
        throw ApiException(code: response.code, message: response.message);
      }
      await loadOrders();
    } finally {
      _cancellingOrderIds.remove(orderId);
    }
  }

  Future<void> confirmReceived(String orderId) async {
    if (orderId.isEmpty || !_confirmingOrderIds.add(orderId)) return;
    try {
      final response = await ref.read(orderRepositoryProvider).confirmReceived(orderId);
      if (!response.success) {
        throw ApiException(code: response.code, message: response.message);
      }
      await loadOrders();
    } finally {
      _confirmingOrderIds.remove(orderId);
    }
  }

  Future<void> _fetch({bool append = false}) async {
    final request = ++_requestVersion;
    final page = append ? state.page + 1 : 1;
    state = state.copyWith(isLoading: !append, isLoadingMore: append);
    try {
      final response = await ref
          .read(orderRepositoryProvider)
          .getOrderList(page: page, pageSize: pageSize, orderState: tabStates[state.activeTabIndex].code, keyword: state.keyword);
      if (!ref.mounted || request != _requestVersion) return;
      if (!response.success || response.data == null) {
        throw ApiException(message: response.success ? '订单列表数据为空' : response.message);
      }
      final result = response.data!;
      final orders = append ? [...state.orders] : <OrderListOrder>[];
      final ids = orders.map((order) => order.id).whereType<String>().toSet();
      for (final order in result.orders) {
        if (order.id == null || ids.add(order.id!)) orders.add(order);
      }
      state = state.copyWith(
        orders: List.unmodifiable(orders),
        isLoading: false,
        isLoadingMore: false,
        page: page,
        total: result.total,
        hasMore: result.hasMore,
      );
    } finally {
      if (ref.mounted && request == _requestVersion && (state.isLoading || state.isLoadingMore)) {
        state = state.copyWith(isLoading: false, isLoadingMore: false);
      }
    }
  }
}

final allOrdersProvider = NotifierProvider.autoDispose<AllOrdersNotifier, AllOrdersState>(AllOrdersNotifier.new);
