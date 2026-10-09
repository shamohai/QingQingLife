import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/enums/order_type.dart';
import '../../domain/repositories/order_repository.dart';

/// 订单卡片展示数据（Presentation 层，由 Provider 从 OrderSummary 转换而来）
class OrderCardItem {
  final String id;
  final String orderNo;
  final OrderType orderType;
  final OrderStatus status;
  final String statusText;
  final String orderPrefix; // "商城订单编号：" / "积分订单编号：" / "服务订单编号："
  final List<OrderItem> items;
  final int? pointsCost; // 积分订单专用
  final String? pickupCode;
  final int totalAmountCents; // 商城/服务订单（cents），积分订单为 0
  final String mainStatusDesc;
  final String subStatusDesc;
  final DateTime createTime;
  final List<OrderActionButton> actions;

  const OrderCardItem({
    required this.id,
    required this.orderNo,
    required this.orderType,
    required this.status,
    required this.statusText,
    required this.orderPrefix,
    required this.items,
    this.pointsCost,
    this.pickupCode,
    required this.totalAmountCents,
    required this.mainStatusDesc,
    required this.subStatusDesc,
    required this.createTime,
    required this.actions,
  });
}

/// 底部操作按钮
class OrderActionButton {
  final String label;
  final bool isPrimary; // true = 蓝色，false = 灰色
  final VoidCallback? onTap;

  const OrderActionButton({
    required this.label,
    this.isPrimary = false,
    this.onTap,
  });
}

/// 全部订单状态
class AllOrdersState {
  final List<OrderCardItem> orders;
  final bool isLoading;
  final int activeTabIndex;

  const AllOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.activeTabIndex = 0,
  });

  AllOrdersState copyWith({List<OrderCardItem>? orders, bool? isLoading, int? activeTabIndex}) {
    return AllOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
    );
  }
}

/// 全部订单 Provider
class AllOrdersNotifier extends Notifier<AllOrdersState> {
  static const _tabLabels = ['全部订单', '待付款', '待发货', '待收货/待核销', '评价', '售后/退款'];

  List<String> get tabLabels => _tabLabels;

  @override
  AllOrdersState build() {
    return const AllOrdersState();
  }

  void selectTab(int index) {
    state = state.copyWith(activeTabIndex: index);
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(orderRepositoryProvider);
      final response = await repository.getOrderList(page: 1, pageSize: 50);
      if (!response.success || response.data == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      final summaries = response.data!.orders;
      final cards = summaries.map(_buildCard).toList();
      state = state.copyWith(orders: cards, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  OrderCardItem _buildCard(OrderSummary summary) {
    return OrderCardItem(
      id: summary.id,
      orderNo: summary.orderNo,
      orderType: summary.orderType,
      status: summary.status,
      statusText: summary.statusText,
      orderPrefix: summary.orderType.label,
      items: [],
      totalAmountCents: summary.totalPriceCents,
      mainStatusDesc: _mainStatusDesc(summary.status),
      subStatusDesc: _subStatusDesc(summary.status),
      createTime: summary.createTime,
      actions: _buildActions(summary),
    );
  }

  String _mainStatusDesc(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingPayment:
        return '付款后预计今天发货';
      case OrderStatus.pendingShipment:
        return '打包中';
      case OrderStatus.shipped:
        return '待收货/待核销';
      case OrderStatus.completed:
        return '已收货';
      default:
        return status.label;
    }
  }

  String _subStatusDesc(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingPayment:
        return '付款后预计今天发货';
      case OrderStatus.pendingShipment:
        return '预计三天后到达';
      case OrderStatus.shipped:
        return '取件码 9-9-8788';
      case OrderStatus.completed:
        return '商品已签收！如有疑问请联系客服';
      default:
        return '';
    }
  }

  List<OrderActionButton> _buildActions(OrderSummary summary) {
    final type = summary.orderType;
    final status = summary.status;
    switch (type) {
      case OrderType.mall:
        switch (status) {
          case OrderStatus.pendingPayment:
            return [
              const OrderActionButton(label: '取消订单'),
              const OrderActionButton(label: '立即付款', isPrimary: true),
            ];
          case OrderStatus.pendingShipment:
            return [
              const OrderActionButton(label: '申请退款'),
              const OrderActionButton(label: '修改地址'),
            ];
          case OrderStatus.shipped:
            return [
              const OrderActionButton(label: '申请退款'),
              const OrderActionButton(label: '确认收货', isPrimary: true),
            ];
          case OrderStatus.completed:
            return [
              const OrderActionButton(label: '申请退款'),
              const OrderActionButton(label: '去评价', isPrimary: true),
            ];
          default:
            return [
              const OrderActionButton(label: '申请退款'),
              const OrderActionButton(label: '查看详情', isPrimary: true),
            ];
        }
      case OrderType.points:
        switch (status) {
          case OrderStatus.pendingShipment:
            return [const OrderActionButton(label: '修改地址')];
          case OrderStatus.shipped:
            return [const OrderActionButton(label: '立即核销', isPrimary: true)];
          default:
            return [const OrderActionButton(label: '修改地址')];
        }
      case OrderType.service:
        return [const OrderActionButton(label: '订单详情')];
    }
  }
}

final allOrdersProvider = NotifierProvider<AllOrdersNotifier, AllOrdersState>(
  () => AllOrdersNotifier(),
);
