import '../../../../core/network/api_response.dart';

/// 发票仓库接口
///
/// TODO(API): 发票中心后端接口尚未定义（一期产品规范中发票仅出现在购物车结算），
/// 当前仅提供接口抽象与 Mock 实现；后端契约就绪后由 Remote 数据源实现本接口，
/// 页面与 Provider 层无需改动。
abstract class InvoiceRepository {
  /// 获取发票列表（分页）
  ///
  /// [status] 为 null 时查询全部
  Future<ApiResponse<InvoiceListResult>> getInvoiceList({required int page, required int pageSize, InvoiceStatus? status});

  /// 获取发票申请记录详情
  Future<ApiResponse<InvoiceDetail>> getInvoiceDetail(String invoiceId);
}

/// 发票状态
enum InvoiceStatus {
  pending('待开票'),
  invoiced('已开票');

  const InvoiceStatus(this.label);
  final String label;
}

/// 发票列表分页结果
class InvoiceListResult {
  final List<InvoiceSummary> invoices;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const InvoiceListResult({required this.invoices, required this.total, required this.page, required this.pageSize, required this.hasMore});
}

/// 发票摘要（发票中心列表展示）
class InvoiceSummary {
  final String id;

  /// 订单商品标题（列表首行，超长省略）
  final String title;

  /// 订单编号，如 DDBH3456789
  final String orderNo;

  /// 订单类型文案，如「商城订单」
  ///
  /// TODO(API): 后端未定义枚举契约，暂以文案字段承载，接口就绪后对齐为枚举。
  final String orderTypeText;

  /// 发票类型文案，如「数电普票」
  ///
  /// TODO(API): 后端未定义枚举契约，暂以文案字段承载，接口就绪后对齐为枚举。
  final String invoiceTypeText;

  /// 开票金额（分）
  final int amountCents;

  /// 开票/订单时间
  final DateTime createTime;

  final InvoiceStatus status;

  const InvoiceSummary({
    required this.id,
    required this.title,
    required this.orderNo,
    required this.orderTypeText,
    required this.invoiceTypeText,
    required this.amountCents,
    required this.createTime,
    required this.status,
  });
}

/// 发票申请记录详情
class InvoiceDetail {
  final String id;
  final String title;

  /// 商品图片资源路径
  final String productImage;

  /// 商品标签，如「52%vol」「清香型」
  ///
  /// TODO(API): 后端未定义标签契约，暂以文案列表承载，接口就绪后对齐。
  final List<String> productTags;

  /// 商品数量
  final int quantity;

  /// 规格文案，如「【规格一】 天佑德电商专供青稞酒特别版本42度500ml」
  final String specText;
  final String orderNo;
  final String orderTypeText;
  final String invoiceTypeText;
  final int amountCents;

  /// 下单时间
  final DateTime orderTime;

  /// 申请时间
  final DateTime applyTime;

  /// 开票时间（未开票时为 null）
  final DateTime? invoiceTime;

  final InvoiceStatus status;

  const InvoiceDetail({
    required this.id,
    required this.title,
    required this.productImage,
    required this.productTags,
    required this.quantity,
    required this.specText,
    required this.orderNo,
    required this.orderTypeText,
    required this.invoiceTypeText,
    required this.amountCents,
    required this.orderTime,
    required this.applyTime,
    required this.invoiceTime,
    required this.status,
  });
}
