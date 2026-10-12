import '../../../../core/network/api_response.dart';
import '../../domain/repositories/invoice_repository.dart';

/// Mock 发票数据源 - 开发/测试环境使用
///
/// TODO(Mock): 发票中心后端接口尚未定义，当前返回本地 Mock 数据用于 UI 还原；
/// 后端就绪后改为 Remote 数据源实现 InvoiceRepository。
class MockInvoiceDataSource implements InvoiceRepository {
  /// Mock 发票列表（与设计稿对齐：待开票 + 已开票 各一条）
  static final List<InvoiceSummary> _mockInvoices = [
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
    await Future.delayed(const Duration(milliseconds: 300));
    final filtered = status == null ? _mockInvoices : _mockInvoices.where((inv) => inv.status == status).toList();
    return ApiResponse.success(InvoiceListResult(invoices: filtered, total: filtered.length, page: page, pageSize: pageSize, hasMore: false));
  }

  /// Mock 发票详情（与列表 Mock 数据对齐，取同 id 的第一条）
  @override
  Future<ApiResponse<InvoiceDetail>> getInvoiceDetail(String invoiceId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final summary = _mockInvoices.where((inv) => inv.id == invoiceId).firstOrNull;
    if (summary == null) {
      return ApiResponse.error('发票不存在');
    }
    var mockTime = DateTime(2026, 10, 1, 12, 30, 9);
    return ApiResponse.success(
      InvoiceDetail(
        id: summary.id,
        title: '天佑德电商专供青稞酒 46度500ml',
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
