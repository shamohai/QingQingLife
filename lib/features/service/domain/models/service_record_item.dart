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

  /// 静态 mock 数据（按设计稿示例文案对齐）
  static const List<ServiceRecordItem> staticList = [
    ServiceRecordItem(
      id: 'r1',
      title: '高尔夫场地预约',
      category: '服务预约',
      status: 'ongoing',
      appointmentId: 'YYBH23456789876543345',
      appointmentTime: '2026-10-01  12:00:00',
    ),
    ServiceRecordItem(
      id: 'r2',
      title: '露营基地',
      category: '服务预约',
      status: 'ongoing',
      appointmentId: 'YYBH23456789876543345',
      appointmentTime: '2026-10-01  12:00:00',
    ),
    ServiceRecordItem(
      id: 'r3',
      title: '露营基地',
      category: '服务预约',
      status: 'ongoing',
      appointmentId: 'YYBH23456789876543345',
      appointmentTime: '2026-10-01  12:00:00',
    ),
    ServiceRecordItem(
      id: 'r4',
      title: '露营基地',
      category: '服务预约',
      status: 'ongoing',
      appointmentId: 'YYBH23456789876543345',
      appointmentTime: '2026-10-01  12:00:00',
    ),
    ServiceRecordItem(
      id: 'r5',
      title: '露营基地',
      category: '服务预约',
      status: 'ongoing',
      appointmentId: 'YYBH23456789876543345',
      appointmentTime: '2026-10-01  12:00:00',
    ),
    ServiceRecordItem(
      id: 'r6',
      title: '露营基地',
      category: '服务预约',
      status: 'ongoing',
      appointmentId: 'YYBH23456789876543345',
      appointmentTime: '2026-10-01  12:00:00',
    ),
    ServiceRecordItem(
      id: 'r7',
      title: '露营基地',
      category: '服务预约',
      status: 'ongoing',
      appointmentId: 'YYBH23456789876543345',
      appointmentTime: '2026-10-01  12:00:00',
    ),
    ServiceRecordItem(
      id: 'r8',
      title: '露营基地',
      category: '服务预约',
      status: 'ongoing',
      appointmentId: 'YYBH23456789876543345',
      appointmentTime: '2026-10-01  12:00:00',
    ),
    ServiceRecordItem(
      id: 'r9',
      title: '露营基地',
      category: '服务预约',
      status: 'ongoing',
      appointmentId: 'YYBH23456789876543345',
      appointmentTime: '2026-10-01  12:00:00',
    ),
    ServiceRecordItem(
      id: 'r10',
      title: '露营基地',
      category: '服务预约',
      status: 'ongoing',
      appointmentId: 'YYBH23456789876543345',
      appointmentTime: '2026-10-01  12:00:00',
    ),
    ServiceRecordItem(
      id: 'r11',
      title: '第一期挚友会',
      category: '挚友报名会',
      status: 'finished',
      appointmentId: 'YYBH23456789876543345',
      appointmentTime: '2026-10-01  12:00:00',
    ),
    ServiceRecordItem(
      id: 'r12',
      title: '挚友会季度活动',
      category: '活动报名',
      status: 'finished',
      appointmentId: 'YYBH23456789876543346',
      appointmentTime: '2026-10-15  14:00:00',
    ),
  ];
}
