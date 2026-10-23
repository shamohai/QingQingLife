/// 预约服务详情模型
///
/// 对应接口：POST /api/sys/app/getreservationservicedetail
/// 请求：{"serviceid": int, "authtoken": "..."}
/// 响应：{"detail": {...}, "myreservationinfo": {...}|null, "result": 0, "descr": null, "datatag": ""}
class ReservationServiceDetail {
  /// 服务 ID
  final int serviceId;

  /// 服务名称
  final String serviceName;

  /// 副标题
  final String subtitle;

  /// 头图 URL
  final String headImgUrl;

  /// 富文本描述（HTML）
  final String descriptionHtml;

  /// 是否展示证件号
  final bool showIdNo;

  /// 最大预约人数（0 表示不限）
  final int maxReservationCount;

  /// 预约须知
  final String reservationRemark;

  /// 用户自身的预约信息（后端尚未提供，当前为 null）
  final Map<String, dynamic>? myReservationInfo;

  /// 日历（后端尚未提供，当前为 null）
  final dynamic calendar;

  const ReservationServiceDetail({
    required this.serviceId,
    required this.serviceName,
    required this.subtitle,
    required this.headImgUrl,
    required this.descriptionHtml,
    required this.showIdNo,
    required this.maxReservationCount,
    required this.reservationRemark,
    this.myReservationInfo,
    this.calendar,
  });

  /// 从扁平行数据（已剔除 result/descr/datatag）中解析
  factory ReservationServiceDetail.fromJson(Map<String, dynamic> json) {
    final detail = json['detail'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final myReservationInfo = json['myreservationinfo'] as Map<String, dynamic>?;
    final calendar = json['calendar'];

    return ReservationServiceDetail(
      serviceId: (detail['serviceid'] as num?)?.toInt() ?? 0,
      serviceName: detail['servicename'] as String? ?? '',
      subtitle: detail['subtitle'] as String? ?? '',
      headImgUrl: detail['headimgurl'] as String? ?? '',
      descriptionHtml: detail['descriptionhtml'] as String? ?? '',
      showIdNo: detail['showidno'] as bool? ?? false,
      maxReservationCount: (detail['maxreservationcount'] as num?)?.toInt() ?? 0,
      reservationRemark: detail['reservationremark'] as String? ?? '',
      myReservationInfo: myReservationInfo,
      calendar: calendar,
    );
  }
}
