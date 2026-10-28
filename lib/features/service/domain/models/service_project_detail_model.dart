import 'service_card_data.dart';

enum ServiceProjectDetailType { appointment, friend, activity }

/// 预约项目详情数据模型
///
/// 同时支持：
/// - mock 活动/挚友数据（heroAsset, detailImageAsset 等）
/// - 真实 API 数据（subtitle, reservationRemark 来自 getreservationservicedetail）
class ServiceProjectDetail {
  final String id;

  /// 项目名称
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

  /// 副标题（来自 API detail.subtitle）
  final String? subtitle;

  /// 预约须知（来自 API detail.reservationremark）
  final String? reservationRemark;

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
    this.subtitle,
    this.reservationRemark,
  });

  /// 一期静态 mock 数据，对应蓝湖设计稿中的山野野营活动
  factory ServiceProjectDetail.mock(String projectId) {
    final source = _lookupMock(projectId);
    final isActivity = source?.tabKey == 'huodong';
    final isFriend = source?.tabKey == 'zhiyouhui';

    return ServiceProjectDetail(
      id: projectId,
      title: source?.title ?? (isActivity ? '活动详情' : '预约项目'),
      heroAsset: source?.heroAsset ?? 'assets/images/service/service_project_hero.png',
      description: source?.description ?? '',
      onBook: () {},
      type: isActivity
          ? ServiceProjectDetailType.activity
          : isFriend
          ? ServiceProjectDetailType.friend
          : ServiceProjectDetailType.appointment,
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