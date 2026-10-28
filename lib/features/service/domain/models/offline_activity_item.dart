/// 线下活动列表单项模型
///
/// 对应接口：POST /api/promotion/app/activity/getofflineactivitylist
/// 参数：{typdsfriends: bool, authtoken: 0, pageindex: int, pagesize: int}
/// 响应：{"activitylist": [...], "result": 0, "descr": null, "datatag": ""}
class OfflineActivityItem {
  /// 活动 ID
  final String activityId;

  /// 活动标题
  final String title;

  /// 活动副标题
  final String subtitle;

  /// 活动限制条件
  final String limitations;

  /// 活动开始日期（yyyy-MM-dd）
  final String startDate;

  /// 活动结束日期（yyyy-MM-dd）
  final String endDate;

  /// 活动状态
  final int status;

  /// 是否可报名
  final bool isSignup;

  /// 头图 URL
  final String postUrl;

  const OfflineActivityItem({
    required this.activityId,
    required this.title,
    required this.subtitle,
    required this.limitations,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isSignup,
    required this.postUrl,
  });

  factory OfflineActivityItem.fromJson(Map<String, dynamic> json) {
    return OfflineActivityItem(
      activityId: json['activityid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      limitations: json['limitations'] as String? ?? '',
      startDate: json['startdate'] as String? ?? '',
      endDate: json['enddate'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      isSignup: json['issignup'] as bool? ?? false,
      postUrl: json['posturl'] as String? ?? '',
    );
  }

  /// 格式化日期范围展示：同一日只显示一个日期，不同日显示 "起始 至 结束"
  String get dateRangeDisplay {
    if (startDate.isEmpty && endDate.isEmpty) return '';
    if (startDate == endDate) return startDate;
    return '$startDate 至 $endDate';
  }
}
