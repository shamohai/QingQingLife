/// 服务预约/活动报名成功页接收的业务上下文。
///
/// 该对象由预约或报名流程传入，不代表后端响应结构。
enum ServiceBookingSuccessSource { reservation, friendActivity, activity }

class ServiceBookingSuccessData {
  final ServiceBookingSuccessSource source;
  final String sourceId;
  final String sourceTitle;

  const ServiceBookingSuccessData({required this.source, required this.sourceId, required this.sourceTitle});
}
