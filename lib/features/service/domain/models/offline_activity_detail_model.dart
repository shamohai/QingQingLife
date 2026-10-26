/// 线下活动详情模型
///
/// 对应接口：POST /api/promotion/app/activity/getofflineactivitydetail
/// 请求：{"activityid": "uuid", "authtoken": 0}
/// 响应：{"detail": {...}, "mysignupinfo": null|{...}, "maxsignupcount": int,
///        "result": 0, "descr": null, "datatag": ""}
class OfflineActivityDetail {
  /// 活动 ID
  final String activityId;

  /// 活动标题
  final String title;

  /// 副标题（可能为 null）
  final String? subtitle;

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

  /// 富文本内容（HTML）
  final String contentHtml;

  /// 最大报名人数（0 表示不限）
  final int maxSignupCount;

  /// 用户自身的报名信息（当前后端为 null）
  final Map<String, dynamic>? mySignupInfo;

  const OfflineActivityDetail({
    required this.activityId,
    required this.title,
    this.subtitle,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isSignup,
    required this.postUrl,
    required this.contentHtml,
    required this.maxSignupCount,
    this.mySignupInfo,
  });

  /// 从扁平行数据（已剔除 result/descr/datatag）中解析
  factory OfflineActivityDetail.fromJson(Map<String, dynamic> json) {
    final detail = json['detail'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return OfflineActivityDetail(
      activityId: detail['activityid'] as String? ?? '',
      title: detail['title'] as String? ?? '',
      subtitle: detail['subtitle'] as String?,
      startDate: detail['startdate'] as String? ?? '',
      endDate: detail['enddate'] as String? ?? '',
      status: (detail['status'] as num?)?.toInt() ?? 0,
      isSignup: detail['issignup'] as bool? ?? false,
      postUrl: detail['posturl'] as String? ?? '',
      contentHtml: detail['contenthtml'] as String? ?? '',
      maxSignupCount: (json['maxsignupcount'] as num?)?.toInt() ?? 0,
      mySignupInfo: json['mysignupinfo'] as Map<String, dynamic>?,
    );
  }

  /// 格式化日期范围：同一日只显示一个日期，不同日显示 "起始 至 结束"
  String get dateRangeDisplay {
    if (startDate.isEmpty && endDate.isEmpty) return '';
    if (startDate == endDate) return startDate;
    return '$startDate 至 $endDate';
  }
}
