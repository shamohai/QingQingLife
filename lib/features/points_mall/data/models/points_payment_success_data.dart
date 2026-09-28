/// 支付成功页导航参数
///
/// 由确认订单页通过 GoRouter extra 传递给 [PointsPaymentSuccessPage]。
class PointsPaymentSuccessData {
  final String orderNo;
  final String transactionNo;
  final int pointsDeducted;

  const PointsPaymentSuccessData({required this.orderNo, required this.transactionNo, this.pointsDeducted = 0});
}
