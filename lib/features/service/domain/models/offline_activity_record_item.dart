/// 活动报名记录单项模型
///
/// 对应接口：POST /api/promotion/app/activity/getmyofflineactivitylist
/// 请求：{"pageindex": int, "pagesize": int}
/// 响应：{"activitylist": [...], "result": 0, "descr": null, "datatag": ""}
class OfflineActivityRecordItem {
  /// 活动 ID
  final String activityId;

  /// 活动标题
  final String title;

  /// 活动类型名称
  final String activityTypeName;

  /// 活动开始日期
  final String activityStartDate;

  /// 活动结束日期
  final String activityEndDate;

  /// 签到时间（可能为空）
  final String? signInTime;

  /// 报名时间
  final String joinTime;

  const OfflineActivityRecordItem({
    required this.activityId,
    required this.title,
    required this.activityTypeName,
    required this.activityStartDate,
    required this.activityEndDate,
    this.signInTime,
    required this.joinTime,
  });

  factory OfflineActivityRecordItem.fromJson(Map<String, dynamic> json) {
    final signInTime = json['signintime'] as String?;
    return OfflineActivityRecordItem(
      activityId: json['activityid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      activityTypeName: json['activitytypename'] as String? ?? '',
      activityStartDate: json['activitystartdate'] as String? ?? '',
      activityEndDate: json['activityenddate'] as String? ?? '',
      signInTime: (signInTime == null || signInTime.isEmpty) ? null : signInTime,
      joinTime: json['jointime'] as String? ?? '',
    );
  }
}
