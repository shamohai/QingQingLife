/// 服务列表卡片数据模型（正式 API 对接后由接口数据填充）
class ServiceCardData {
  final String id;
  final String imageAsset;
  final String title;
  final String subtitle;
  final String buttonText;
  final String? heroAsset; // 详情页头图，可选
  final String? description; // 详情页描述，可选
  final String? dateRange; // 活动日期范围，如 "2026-08-01 至 2026-09-01"
  final int? limitCount; // 人数限制
  final String? registrationRange;
  final String? activityAddress;
  final String? detailImageAsset;

  /// 所属分类 Tab key：'fuwu' | 'zhiyouhui' | 'huodong' | 'goujiu'
  final String tabKey;

  const ServiceCardData({
    required this.id,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    this.buttonText = '立即预约',
    this.heroAsset,
    this.description,
    this.dateRange,
    this.limitCount,
    this.registrationRange,
    this.activityAddress,
    this.detailImageAsset,
    required this.tabKey,
  });
}
