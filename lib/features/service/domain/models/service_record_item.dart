/// 服务预约/报名记录数据模型（独立于服务卡片）
class ServiceRecordItem {
  final String id;
  final String title;

  /// 分类标签文本，如"挚友报名会"、"服务预约"、"活动报名"
  final String category;
  final String status; // ongoing | finished（对应设计稿"已预约"和"已结束"两态）
  /// 预约编号
  final String appointmentId;

  /// 预约时间
  final String appointmentTime;

  const ServiceRecordItem({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.appointmentId,
    required this.appointmentTime,
  });
}
