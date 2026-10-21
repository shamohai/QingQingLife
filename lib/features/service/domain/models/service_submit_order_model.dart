/// 提交权益团购订单响应模型
///
/// 对应接口：POST /api/groupMall/order/submitgrouporder
/// 请求：{"sharecartid": int, "addressid": int}
/// 响应（扁平格式）：
/// ```
/// {
///   "result": int (错误号，0表示成功),
///   "descr": string (错误描述),
///   "guidetext": string,
///   "orderid": int (成功后返回)
/// }
/// ```
class ServiceSubmitOrderResult {
  final String guidetext;
  final int orderId;
  final int result;
  final String descr;

  const ServiceSubmitOrderResult({required this.guidetext, required this.orderId, required this.result, required this.descr});

  factory ServiceSubmitOrderResult.fromJson(Map<String, dynamic> json) {
    return ServiceSubmitOrderResult(
      guidetext: json['guidetext'] as String? ?? '',
      orderId: (json['orderid'] as num?)?.toInt() ?? 0,
      // 扁平响应会在 ApiResponse 中剥离顶层 result；能进入此解析器代表外层状态已成功。
      result: (json['result'] as num?)?.toInt() ?? 0,
      descr: json['descr'] as String? ?? '',
    );
  }
}
