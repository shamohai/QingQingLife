import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/repositories/invoice_repository.dart';

/// 统一发票数据源（实现 InvoiceRepository 接口）
class InvoiceDataSource implements InvoiceRepository {
  const InvoiceDataSource({ApiClient? apiClient});

  static final List<InvoiceSummary> _fallbackInvoices = [
    InvoiceSummary(
      id: 'inv_pending_1',
      title: '天佑德电商专供青稞酒 46度500ml',
      orderNo: 'DDBH3456789',
      orderTypeText: '商城订单',
      invoiceTypeText: '数电普票',
      amountCents: 80000,
      createTime: DateTime(2026, 10, 1, 12, 30, 9),
      status: InvoiceStatus.pending,
    ),
    InvoiceSummary(
      id: 'inv_invoiced_1',
      title: '天佑德电商专供青稞酒 46度500ml',
      orderNo: 'DDBH3456789',
      orderTypeText: '商城订单',
      invoiceTypeText: '数电普票',
      amountCents: 80000,
      createTime: DateTime(2026, 10, 1, 12, 30, 9),
      status: InvoiceStatus.invoiced,
    ),
  ];

  @override
  Future<ApiResponse<InvoiceListResult>> getInvoiceList({required int page, required int pageSize, InvoiceStatus? status}) async {
    final filtered = status == null ? _fallbackInvoices : _fallbackInvoices.where((inv) => inv.status == status).toList();
    return ApiResponse.success(InvoiceListResult(invoices: filtered, total: filtered.length, page: page, pageSize: pageSize, hasMore: false));
  }

  @override
  Future<ApiResponse<InvoiceDetail>> getInvoiceDetail(String invoiceId) async {
    final summary = _fallbackInvoices.where((inv) => inv.id == invoiceId).firstOrNull ?? _fallbackInvoices.first;
    var mockTime = DateTime(2026, 10, 1, 12, 30, 9);
    return ApiResponse.success(
      InvoiceDetail(
        id: summary.id,
        title: summary.title,
        productImage: 'assets/images/product/product1.jpg',
        productTags: const ['52%vol', '清香型'],
        quantity: 1,
        specText: '【规格一】 天佑德电商专供青稞酒特别版本42度500ml',
        orderNo: summary.orderNo,
        orderTypeText: summary.orderTypeText,
        invoiceTypeText: summary.invoiceTypeText,
        amountCents: summary.amountCents,
        orderTime: mockTime,
        applyTime: mockTime,
        invoiceTime: summary.status == InvoiceStatus.invoiced ? mockTime : null,
        status: summary.status,
      ),
    );
  }
}

final invoiceDataSourceProvider = Provider<InvoiceDataSource>((ref) {
  return const InvoiceDataSource();
});
