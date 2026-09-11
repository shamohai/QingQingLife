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
    this.buttonText = '立即参与',
  });

  static const List<ServiceCardData> staticList = [
    ServiceCardData(
      id: 'service_yuyue',
      imageAsset: 'assets/images/service/service_yuyue.webp',
      title: '服务预约',
      subtitle: '当前有100人参与预约',
    ),
    ServiceCardData(
      id: 'service_zhiyouhui',
      imageAsset: 'assets/images/service/service_zhiyouhui.webp',
      title: '挚友会报名',
      subtitle: '当前有100人参与报名',
    ),
    ServiceCardData(
      id: 'service_huodong',
      imageAsset: 'assets/images/service/service_huodong.webp',
      title: '活动报名',
      subtitle: '当前有100人参与报名',
    ),
    ServiceCardData(
      id: 'service_goujiu',
      imageAsset: 'assets/images/service/service_goujiu.webp',
      title: '购酒享服务',
      subtitle: '当前有100人参与报名',
    ),
  ];
}
