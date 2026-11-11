import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qingqinglife/core/logging/app_logger.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/invoice_repository.dart';

/// 发票中心页签索引：0=全部 1=待开票 2=已开票
const kInvoiceTabCount = 3;

/// 发票中心状态
class InvoiceCenterState {
  final List<InvoiceSummary> invoices;
  final bool isLoading;
  final bool isLoadingMore;

  /// 加载失败信息；非空时页面展示错误态（可重试）
  final String? errorMessage;

  final int activeTabIndex;

  /// 是否已成功加载过一次（用于区分首屏加载与下拉刷新）
  final bool hasLoaded;

  const InvoiceCenterState({
    this.invoices = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.activeTabIndex = 0,
    this.hasLoaded = false,
  });

  InvoiceCenterState copyWith({
    List<InvoiceSummary>? invoices,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? activeTabIndex,
    bool? hasLoaded,
  }) {
    return InvoiceCenterState(
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }

  /// 当前页签过滤后的列表
  List<InvoiceSummary> get filteredInvoices {
    switch (activeTabIndex) {
      case 1:
        return invoices.where((inv) => inv.status == InvoiceStatus.pending).toList();
      case 2:
        return invoices.where((inv) => inv.status == InvoiceStatus.invoiced).toList();
      default:
        return invoices;
    }
  }
}

/// 发票中心控制器
///
/// 数据链路：Page → [invoiceCenterProvider] → InvoiceRepository → DataSource
class InvoiceCenterNotifier extends Notifier<InvoiceCenterState> {
  @override
  InvoiceCenterState build() {
    return const InvoiceCenterState();
  }

  /// 切换页签
  void selectTab(int index) {
    if (index == state.activeTabIndex) return;
    state = state.copyWith(activeTabIndex: index.clamp(0, kInvoiceTabCount - 1));
  }

  /// 加载发票列表（首页数据，供进入页面/重试/下拉刷新调用）
  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(invoiceRepositoryProvider);
      final response = await repository.getInvoiceList(page: 1, pageSize: 50);
      if (response.success && response.data != null) {
        state = state.copyWith(invoices: response.data!.invoices, isLoading: false, hasLoaded: true, errorMessage: null);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: '发票信息加载失败，请稍后重试');
      }
    } catch (e) {
      AppLogger.error('load error', module: 'invoice_center', error: e);
      state = state.copyWith(isLoading: false, errorMessage: '发票信息加载失败，请稍后重试');
    }
  }

  /// 加载更多（分页预留；Mock 数据 hasMore=false，不会触发）
  Future<void> loadMore() async {
    // TODO(API): 后端分页契约就绪后实现翻页加载
  }
}

final invoiceCenterProvider = NotifierProvider<InvoiceCenterNotifier, InvoiceCenterState>(() => InvoiceCenterNotifier());
