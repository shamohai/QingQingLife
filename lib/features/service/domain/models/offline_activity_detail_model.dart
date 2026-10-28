/// 线下活动详情模型
///
/// 对应接口：POST /api/promotion/app/activity/getofflineactivitydetail
/// 请求：{"activityid": "uuid", "authtoken": 0}
/// 响应：{"detail": {...}, "mysignupinfo": null|{...}, "maxsignupcount": int,
///        "addresslist": [...], "result": 0, "descr": null, "datatag": ""}
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

  /// 消息/描述
  final String message;

  /// 最大报名人数（0 表示不限）
  final int maxSignupCount;

  /// 用户自身的报名信息（当前后端为 null）
  final MySignupInfo? mySignupInfo;

  /// 活动地址列表
  final List<ActivityAddress> addressList;

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
    required this.message,
    required this.maxSignupCount,
    this.mySignupInfo,
    this.addressList = const [],
  });

  /// 从扁平行数据（已剔除 result/descr/datatag）中解析
  factory OfflineActivityDetail.fromJson(Map<String, dynamic> json) {
    final detail = json['detail'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final mySignupInfoJson = json['mysignupinfo'] as Map<String, dynamic>?;
    final addressListJson = detail['addresslist'] as List<dynamic>?;
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
      message: detail['message'] as String? ?? '',
      maxSignupCount: (json['maxsignupcount'] as num?)?.toInt() ?? 0,
      mySignupInfo: mySignupInfoJson != null ? MySignupInfo.fromJson(mySignupInfoJson) : null,
      addressList: addressListJson?.map((e) => ActivityAddress.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  /// 格式化日期范围：同一日只显示一个日期，不同日显示 "起始 至 结束"
  String get dateRangeDisplay {
    if (startDate.isEmpty && endDate.isEmpty) return '';
    if (startDate == endDate) return startDate;
    return '$startDate 至 $endDate';
  }
}

/// 用户自身的报名信息
///
/// 对应接口返回的 mysignupinfo 对象结构：
/// {
///   "signupid": "",
///   "scrmmemberid": "",
///   "username": "",
///   "phone": "",
///   "idno": "",
///   "remark": "",
///   "signupusercount": ""
/// }
class MySignupInfo {
  /// 报名 ID
  final String signupId;

  /// SCRM 会员 ID
  final String scrmMemberId;

  /// 用户名/联系人姓名
  final String username;

  /// 联系电话
  final String phone;

  /// 身份证号
  final String idNo;

  /// 备注
  final String remark;

  /// 报名总人数（含本人）
  final int signupUserCount;

  const MySignupInfo({
    required this.signupId,
    required this.scrmMemberId,
    required this.username,
    required this.phone,
    required this.idNo,
    required this.remark,
    required this.signupUserCount,
  });

  factory MySignupInfo.fromJson(Map<String, dynamic> json) {
    return MySignupInfo(
      signupId: json['signupid'] as String? ?? '',
      scrmMemberId: json['scrmmemberid'] as String? ?? '',
      username: json['username'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      idNo: json['idno'] as String? ?? '',
      remark: json['remark'] as String? ?? '',
      signupUserCount: (json['signupusercount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 活动地址模型
///
/// 对应接口返回的 addresslist 数组项结构：
/// {
///   "id": "",
///   "address": "",
///   "activityid": "",
///   "coordinate": ""
/// }
class ActivityAddress {
  /// 地址 ID
  final String id;

  /// 详细地址
  final String address;

  /// 关联活动 ID
  final String activityId;

  /// 坐标（经纬度，如 "116.397428,39.90923"）
  final String coordinate;

  const ActivityAddress({required this.id, required this.address, required this.activityId, required this.coordinate});

  factory ActivityAddress.fromJson(Map<String, dynamic> json) {
    return ActivityAddress(
      id: json['id'] as String? ?? '',
      address: json['address'] as String? ?? '',
      activityId: json['activityid'] as String? ?? '',
      coordinate: json['coordinate'] as String? ?? '',
    );
  }
}
