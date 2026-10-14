import 'service_card_data.dart';

enum ServiceProjectDetailType { appointment, activity }

/// 预约项目详情数据模型（本地 mock，待 API 对接后替换）
class ServiceProjectDetail {
  final String id;

  /// 项目名称（从 ServiceCardData.title 查找，未找到时回退 '预约项目'）
  final String title;
  final String heroAsset;
  final String description;
  final Function onBook;
  final ServiceProjectDetailType type;
  final String? activityTime;
  final String? registrationTime;
  final String? activityAddress;
  final int? limitCount;
  final String? detailImageAsset;

  const ServiceProjectDetail({
    required this.id,
    required this.title,
    required this.heroAsset,
    required this.description,
    required this.onBook,
    required this.type,
    this.activityTime,
    this.registrationTime,
    this.activityAddress,
    this.limitCount,
    this.detailImageAsset,
  });

  /// 一期静态 mock 数据，对应蓝湖设计稿中的山野野营活动
  factory ServiceProjectDetail.mock(String projectId) {
    final source = _lookupMock(projectId);
    final isActivity = source?.tabKey == 'huodong';

    return ServiceProjectDetail(
      id: projectId,
      title: source?.title ?? (isActivity ? '活动详情' : '预约项目'),
      heroAsset: source?.heroAsset ?? 'assets/images/service/service_project_hero.png',
      description: source?.description ?? '',
      onBook: () {},
      type: isActivity ? ServiceProjectDetailType.activity : ServiceProjectDetailType.appointment,
      activityTime: source?.dateRange,
      registrationTime: source?.registrationRange,
      activityAddress: source?.activityAddress,
      limitCount: source?.limitCount,
      detailImageAsset: source?.detailImageAsset,
    );
  }

  /// 从静态 mock 数据查找项目名称，找不到时回退为 '预约项目'
  static ServiceCardData? _lookupMock(String projectId) {
    for (final list in ServiceCardData.staticListByTab.values) {
      for (final card in list) {
        if (card.id == projectId) return card;
      }
    }
    return null;
  }
}
