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
  final String contacttPhone;

  /// 客服备注文案（如"客服电话（周一至周五 9:00 ~ 17:00)："）
  final String contactRemark;

  /// 客服微信二维码图片 URL
  final String serviceQrImg;

  /// 企业微信客服小程序路径
  final String workWxMpPath;

  /// 客服联系人姓名
  final String contactName;

  /// 用户已选购的购物车信息，未选购或未登录时为 null
  final CartInfo? cartInfo;

  const ShareCartTemplateDetail({
    required this.templateId,
    required this.templateName,
    required this.headImg,
    required this.requirements,
    required this.descriptionHtml,
    required this.contacttPhone,
    required this.contactRemark,
    required this.serviceQrImg,
    required this.workWxMpPath,
    required this.contactName,
    required this.cartInfo,
  });

  factory ShareCartTemplateDetail.fromJson(Map<String, dynamic> json) {
    // 扁平响应：templateinfo 字段包裹实际数据
    final Map<String, dynamic> info = (json['templateinfo'] as Map?)?.cast<String, dynamic>() ?? {};
    final Map<String, dynamic> customerServiceInfo = (json['templatecustomerserviceinfo'] as Map?)?.cast<String, dynamic>() ?? {};
    final Map<String, dynamic>? cartInfoJson = (json['cartinfo'] as Map?)?.cast<String, dynamic>();
    return ShareCartTemplateDetail(
      templateId: (info['templateid'] as num?)?.toInt() ?? 0,
      templateName: info['templatename'] as String? ?? '',
      headImg: info['headimg'] as String? ?? '',
      requirements: info['requirements'] as String? ?? '',
      descriptionHtml: info['descriptionhtml'] as String? ?? '',
      contacttPhone: customerServiceInfo['contacttphone'] as String? ?? '',
      contactRemark: customerServiceInfo['contactremark'] as String? ?? '',
      serviceQrImg: customerServiceInfo['workwxqrimg'] as String? ?? '',
      workWxMpPath: customerServiceInfo['workwxmppath'] as String? ?? '',
      contactName: customerServiceInfo['contactname'] as String? ?? '',
      cartInfo: cartInfoJson != null ? CartInfo.fromJson(cartInfoJson) : null,
    );
  }
}

/// 购物车信息模型
class CartInfo {
  /// 购物车 ID
  final int cartId;

  /// 已选购的商品数量
  final int currentProductCount;

  /// 已选购的商品总金额
  final double currentOrderAmount;

  const CartInfo({
    required this.cartId,
    required this.currentProductCount,
    required this.currentOrderAmount,
  });

  factory CartInfo.fromJson(Map<String, dynamic> json) {
    return CartInfo(
      cartId: (json['cartid'] as num?)?.toInt() ?? 0,
      currentProductCount: (json['currentproductcount'] as num?)?.toInt() ?? 0,
      currentOrderAmount: (json['currentorderamount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
