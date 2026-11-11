enum ServiceProjectDetailType { appointment, friend, activity }

/// 预约项目详情数据模型
///
/// 数据来源：getreservationservicedetail 接口。
/// 活动/挚友类字段（activityTime 等）待对应接口接入后再填充。
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
}
