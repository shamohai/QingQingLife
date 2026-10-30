/// 本地服务预约/活动报名成功页上下文。
///
/// 该模型只负责页面展示和记录页分流，不代表后端响应结构。
enum ServiceBookingSuccessSource { reservation, friendActivity, activity }

class ServiceBookingSuccessData {
  final ServiceBookingSuccessSource source;
  final String sourceId;
  final String sourceTitle;
  final String recordTab;

  const ServiceBookingSuccessData({required this.source, required this.sourceId, required this.sourceTitle, required this.recordTab});

  const ServiceBookingSuccessData.activityMock()
    : source = ServiceBookingSuccessSource.activity,
      sourceId = 'mock_activity_001',
      sourceTitle = '山野露营活动',
      recordTab = 'activity';

  const ServiceBookingSuccessData.reservationMock()
    : source = ServiceBookingSuccessSource.reservation,
      sourceId = 'mock_reservation_001',
      sourceTitle = '高尔夫场地预约',
      recordTab = 'reservation';
}
