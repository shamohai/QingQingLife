/// 购酒享服务模板详情模型
///
/// 对应接口：POST /api/groupMall/shareCart/gettemplatedetail
/// 请求参数：{"templateid": int}
/// 响应格式：扁平结构（result=0 成功），数据字段直接返回
class ShareCartTemplateDetail {
  /// 模板 ID
  final int templateId;

  /// 模板名称
  final String templateName;

  /// 头图 URL（网络图片）
  final String headImg;

  /// 要求说明，展示给用户
  final String requirements;

  /// 详情 HTML 富文本（含活动规则等）
  final String descriptionHtml;

  /// 客服电话
  final String contactPhone;

  /// 客服备注文案（如"客服电话（周一至周五 9:00 ~ 17:00)："）
  final String contactRemark;

  /// 客服微信二维码图片 URL
  final String serviceQrImg;

  const ShareCartTemplateDetail({
    required this.templateId,
    required this.templateName,
    required this.headImg,
    required this.requirements,
    required this.descriptionHtml,
    required this.contactPhone,
    required this.contactRemark,
    required this.serviceQrImg,
  });

  factory ShareCartTemplateDetail.fromJson(Map<String, dynamic> json) {
    // 扁平响应：templateinfo 字段包裹实际数据
    final Map<String, dynamic> info = (json['templateinfo'] as Map?)?.cast<String, dynamic>() ?? {};
    return ShareCartTemplateDetail(
      templateId: (info['templateid'] as num?)?.toInt() ?? 0,
      templateName: info['templatename'] as String? ?? '',
      headImg: info['headimg'] as String? ?? '',
      requirements: info['requirements'] as String? ?? '',
      descriptionHtml: info['descriptionhtml'] as String? ?? '',
      contactPhone: (json['templatecustomerserviceinfo'] as Map?)?['contactphone'] as String? ?? '',
      contactRemark: (json['templatecustomerserviceinfo'] as Map?)?['contactremark'] as String? ?? '',
      serviceQrImg: (json['templatecustomerserviceinfo'] as Map?)?['workwxqrimg'] as String? ?? '',
    );
  }
}
