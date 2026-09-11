/// 服务预约/报名记录数据模型（独立于服务卡片）
class ServiceRecordItem {
  final String id;
  final String title;
  final String status; // ongoing | ended | upcoming

  const ServiceRecordItem({
    required this.id,
    required this.title,
    this.status = 'ongoing',
  });

  /// 静态 mock 数据
  static const List<ServiceRecordItem> staticList = [
    ServiceRecordItem(id: 'r1', title: '高尔夫场地预约', status: 'ongoing'),
    ServiceRecordItem(id: 'r2', title: '挚友会季度活动', status: 'upcoming'),
    ServiceRecordItem(id: 'r3', title: '跑步俱乐部月赛', status: 'ended'),
    ServiceRecordItem(id: 'r4', title: '自行车骑行活动', status: 'ongoing'),
  ];
}
