/// 购酒享服务模板模型
///
/// 对应接口：POST /api/groupMall/shareCart/gettemplatelist
class ShareCartTemplate {
  /// 模板 ID
  final int templateId;

  /// 模板名称
  final String templateName;

  /// 头图 URL（网络图片）
  final String headImg;

  /// 要求说明，展示给用户
  final String requirements;

  const ShareCartTemplate({
    required this.templateId,
    required this.templateName,
    required this.headImg,
    required this.requirements,
  });

  factory ShareCartTemplate.fromJson(Map<String, dynamic> json) {
    return ShareCartTemplate(
      templateId: (json['templateid'] as num?)?.toInt() ?? 0,
      templateName: json['templatename'] as String? ?? '',
      headImg: json['headimg'] as String? ?? '',
      requirements: json['requirements'] as String? ?? '',
    );
  }
}
