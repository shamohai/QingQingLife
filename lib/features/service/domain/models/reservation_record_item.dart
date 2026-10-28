/// 预约/报名记录列表单项模型
///
/// 对应接口：POST /api/sys/app/getmyreservationlist
/// 请求：{"reservationlisttype": int, "pageindex": int, "pagesize": int}
/// 响应：{"list": [...], "result": 0, "descr": null, "datatag": ""}
///
/// reservationlisttype:
///   0 = 全部
///   1 = 已预约（默认）
///   2 = 已完成
class ReservationRecordItem {
  /// 预约 ID
  final int reservationId;

  /// 服务 ID
  final int serviceId;

  /// 服务名称
  final String serviceName;

  /// 服务类型名称（如"服务预约"、"活动报名"）
  final String serviceTypeName;

  /// 审核文本（拒绝原因 / 通过后备注）
  final String auditText;

  /// 联系人姓名
  final String contactName;

  /// 联系电话
  final String contactPhoneNumber;

  /// 证件号
  final String idNo;

  /// 用户备注
  final String remark;

  /// 预约日期（yyyy-MM-dd）
  final String reservationDate;

  /// 预约日期时间（yyyy-MM-dd HH:mm:ss）
  final String reservationDateTime;

  /// 预约时段（HH:mm）
  final String reservationTime;

  /// 状态码（1=待审核 等）
  final int status;

  /// 状态名称（如"待审核"、"已通过"、"已拒绝"）
  final String statusName;

  /// 预约人数
  final int userCount;

  const ReservationRecordItem({
    required this.reservationId,
    required this.serviceId,
    required this.serviceName,
    required this.serviceTypeName,
    required this.auditText,
    required this.contactName,
    required this.contactPhoneNumber,
    required this.idNo,
    required this.remark,
    required this.reservationDate,
    required this.reservationDateTime,
    required this.reservationTime,
    required this.status,
    required this.statusName,
    required this.userCount,
  });

  factory ReservationRecordItem.fromJson(Map<String, dynamic> json) {
    return ReservationRecordItem(
      reservationId: (json['reservationid'] as num?)?.toInt() ?? 0,
      serviceId: (json['serviceid'] as num?)?.toInt() ?? 0,
      serviceName: json['servicename'] as String? ?? '',
      serviceTypeName: json['servicetypename'] as String? ?? '',
      auditText: json['audittext'] as String? ?? '',
      contactName: json['contactname'] as String? ?? '',
      contactPhoneNumber: json['contactphonenumber'] as String? ?? '',
      idNo: json['idno'] as String? ?? '',
      remark: json['remark'] as String? ?? '',
      reservationDate: json['reservationdate'] as String? ?? '',
      reservationDateTime: json['reservationdatetime'] as String? ?? '',
      reservationTime: json['reservationtime'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      statusName: json['statusname'] as String? ?? '',
      userCount: (json['usercount'] as num?)?.toInt() ?? 0,
    );
  }
}
