/// 服务列表卡片数据模型（mock 数据，正式 API 对接后替换）
class ServiceCardData {
  final String id;
  final String imageAsset;
  final String title;
  final String subtitle;
  final String buttonText;

  const ServiceCardData({
    required this.id,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    this.buttonText = '立即预约',
  });

  /// 静态 mock 数据，对应蓝湖设计稿版本3
  static const List<ServiceCardData> staticList = [
    ServiceCardData(
      id: 'golf',
      imageAsset: 'assets/images/service/service_golf.png',
      title: '高尔夫',
      subtitle: '当前已有100人参与预约',
    ),
    ServiceCardData(
      id: 'running',
      imageAsset: 'assets/images/service/service_running.png',
      title: '跑步',
      subtitle: '当前已有100人参与预约',
    ),
    ServiceCardData(
      id: 'cycling',
      imageAsset: 'assets/images/service/service_cycling.png',
      title: '自行车',
      subtitle: '当前已有100人参与预约',
    ),
    ServiceCardData(
      id: 'camping',
      imageAsset: 'assets/images/service/service_camping.png',
      title: '露营基地',
      subtitle: '当前已有100人参与预约',
    ),
  ];
}
