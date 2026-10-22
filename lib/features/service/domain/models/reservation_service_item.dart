/// 服务预约列表单项模型
///
/// 对应接口：POST /api/sys/app/getreservationservicelist
class ReservationServiceItem {
  /// 服务 ID
  final int serviceId;

  /// 服务名称
  final String serviceName;

  /// 副标题
  final String subtitle;

  /// 头图 URL
  final String headImgUrl;

  /// 富文本描述
  final String descriptionHtml;

  const ReservationServiceItem({
    required this.serviceId,
    required this.serviceName,
    required this.subtitle,
    required this.headImgUrl,
    required this.descriptionHtml,
  });

  factory ReservationServiceItem.fromJson(Map<String, dynamic> json) {
    return ReservationServiceItem(
      serviceId: (json['serviceid'] as num?)?.toInt() ?? 0,
      serviceName: json['servicename'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      headImgUrl: json['headimgurl'] as String? ?? '',
      descriptionHtml: json['descriptionhtml'] as String? ?? '',
    );
  }
}
