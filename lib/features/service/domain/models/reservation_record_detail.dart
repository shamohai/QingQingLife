/// 预约记录详情模型。
///
/// 对应接口：POST /api/sys/app/getmyreservationdetail
/// 请求：{"reservationid": int}
/// 响应：{"info": {...}, "result": 0, "descr": null, "datatag": ""}
class ReservationRecordDetail {
  final String serviceName;
  final String serviceTypeName;
  final String headImgUrl;
  final int reservationId;
  final int serviceId;
  final String contactName;
  final String contactPhoneNumber;
  final String reservationDateTime;
  final String reservationDate;
  final String reservationTime;
  final String idNo;
  final int userCount;
  final String remark;
  final int status;
  final String statusName;
  final String auditText;

  const ReservationRecordDetail({
    required this.serviceName,
    required this.serviceTypeName,
    required this.headImgUrl,
    required this.reservationId,
    required this.serviceId,
    required this.contactName,
    required this.contactPhoneNumber,
    required this.reservationDateTime,
    required this.reservationDate,
    required this.reservationTime,
    required this.idNo,
    required this.userCount,
    required this.remark,
    required this.status,
    required this.statusName,
    required this.auditText,
  });

  factory ReservationRecordDetail.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return ReservationRecordDetail(
      serviceName: info['servicename'] as String? ?? '',
      serviceTypeName: info['servicetypename'] as String? ?? '',
      headImgUrl: info['headimg'] as String? ?? '',
      reservationId: (info['reservationid'] as num?)?.toInt() ?? 0,
      serviceId: (info['serviceid'] as num?)?.toInt() ?? 0,
      contactName: info['contactname'] as String? ?? '',
      contactPhoneNumber: info['contactphonenumber'] as String? ?? '',
      reservationDateTime: info['reservationdatetime'] as String? ?? '',
      reservationDate: info['reservationdate'] as String? ?? '',
      reservationTime: info['reservationtime'] as String? ?? '',
      idNo: info['idno'] as String? ?? '',
      userCount: (info['usercount'] as num?)?.toInt() ?? 0,
      remark: info['remark'] as String? ?? '',
      status: (info['status'] as num?)?.toInt() ?? 0,
      statusName: info['statusname'] as String? ?? '',
      auditText: info['audittext'] as String? ?? '',
    );
  }
}
