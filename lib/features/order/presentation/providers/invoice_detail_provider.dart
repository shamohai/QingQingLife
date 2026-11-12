import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/invoice_repository.dart';

/// 发票申请记录详情状态
class InvoiceDetailState {
  final InvoiceDetail? detail;
  final bool isLoading;

  /// 加载失败信息；非空时页面展示错误态（可重试）
  final String? errorMessage;

  const InvoiceDetailState({this.detail, this.isLoading = false, this.errorMessage});

  InvoiceDetailState copyWith({InvoiceDetail? detail, bool? isLoading, String? errorMessage}) {
    return InvoiceDetailState(detail: detail ?? this.detail, isLoading: isLoading ?? this.isLoading, errorMessage: errorMessage);
  }
}

/// 发票申请记录详情控制器（family，参数为发票 id）
///
/// Riverpod 3 的 family notifier 写法：普通 [Notifier] + 构造函数接收参数，
/// 与项目 shop_paging_providers 保持一致（3.0 起已移除 FamilyNotifier）。
/// 数据链路：Page → [invoiceDetailProvider] → InvoiceRepository → DataSource
class InvoiceDetailNotifier extends Notifier<InvoiceDetailState> {
  final String invoiceId;

  InvoiceDetailNotifier(this.invoiceId);

  @override
  InvoiceDetailState build() {
    return const InvoiceDetailState();
  }

  /// 加载发票详情（供进入页面/重试调用）
  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(invoiceRepositoryProvider);
      final response = await repository.getInvoiceDetail(invoiceId);
      if (response.success && response.data != null) {
        state = state.copyWith(detail: response.data, isLoading: false, errorMessage: null);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: '发票详情加载失败，请稍后重试');
      }
    } finally {
      if (state.isLoading) state = state.copyWith(isLoading: false);
    }
  }
}

final invoiceDetailProvider = NotifierProvider.autoDispose.family<InvoiceDetailNotifier, InvoiceDetailState, String>(
  (invoiceId) => InvoiceDetailNotifier(invoiceId),
);
