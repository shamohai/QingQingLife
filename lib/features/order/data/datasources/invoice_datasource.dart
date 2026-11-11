import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../domain/repositories/invoice_repository.dart';

/// 统一发票数据源（实现 InvoiceRepository 接口）
///
/// 发票中心后端接口尚未定义，当前不提供任何伪造数据。
/// 所有方法返回失败结果，由页面的 Error 状态承接；接口就绪后在此替换实现即可。
class InvoiceDataSource implements InvoiceRepository {
  /// 后端接口就绪后用于发起真实请求。
  final ApiClient? apiClient;

  const InvoiceDataSource({this.apiClient});

  static const _notAvailable = '发票功能暂未开放，请稍后再试';

  @override
  Future<ApiResponse<InvoiceListResult>> getInvoiceList({required int page, required int pageSize, InvoiceStatus? status}) async {
    return ApiResponse.error(_notAvailable);
  }

  @override
  Future<ApiResponse<InvoiceDetail>> getInvoiceDetail(String invoiceId) async {
    return ApiResponse.error(_notAvailable);
  }
}

final invoiceDataSourceProvider = Provider<InvoiceDataSource>((ref) {
  return InvoiceDataSource(apiClient: ref.read(apiClientProvider));
});
