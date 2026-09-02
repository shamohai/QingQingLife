/// 会员权益权限接口响应 Model
/// 
/// 接口：POST /api/sys/v2/getmemberauthority
/// 请求：{"level": int}
/// 响应（成功时 result=0）：
///   {
///     auths: [{auth, authname, introduce, isown, isuse, tipsmsg, showimg, url, newwelfare, sort}],
///     username, level, effectivetime, lowlevelcredit, nextlevelcredit,
///     result, descr, datatag
///   }
class MemberAuthorityModel {
  /// 权限列表
  final List<MemberAuthItem> auths;

  /// 用户名（服务端填充）
  final String? username;

  /// 当前等级
  final int? level;

  /// 有效期时间戳
  final String? effectivetime;

  /// 当前等级所需积分
  final int lowlevelcredit;

  /// 下一级所需积分
  final int nextlevelcredit;

  const MemberAuthorityModel({
    required this.auths,
    this.username,
    this.level,
    this.effectivetime,
    this.lowlevelcredit = 0,
    this.nextlevelcredit = 0,
  });

  factory MemberAuthorityModel.fromJson(Map<String, dynamic> json) {
    return MemberAuthorityModel(
      auths: (json['auths'] as List<dynamic>?)
              ?.map((e) => MemberAuthItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      username: json['username'] as String?,
      level: json['level'] as int?,
      effectivetime: json['effectivetime'] as String?,
      lowlevelcredit: json['lowlevelcredit'] as int? ?? 0,
      nextlevelcredit: json['nextlevelcredit'] as int? ?? 0,
    );
  }
}

/// 单项会员权益
class MemberAuthItem {
  /// 权益标识（如 9=专卖店折扣，2=产品定制，1=新品试饮等）
  final int auth;

  /// 权益名称
  final String authname;

  /// 权益介绍
  final String introduce;

  /// 是否已拥有
  final bool isown;

  /// 是否正在使用
  final bool isuse;

  /// 提示消息（未拥有时的引导文案）
  final String tipsmsg;

  /// 展示图片 URL
  final String? showimg;

  /// 跳转 URL
  final String? url;

  /// 是否为新福利
  final bool newwelfare;

  /// 排序权重
  final int sort;

  const MemberAuthItem({
    required this.auth,
    required this.authname,
    required this.introduce,
    required this.isown,
    required this.isuse,
    required this.tipsmsg,
    this.showimg,
    this.url,
    required this.newwelfare,
    required this.sort,
  });

  factory MemberAuthItem.fromJson(Map<String, dynamic> json) {
    return MemberAuthItem(
      auth: json['auth'] as int? ?? 0,
      authname: json['authname'] as String? ?? '',
      introduce: json['introduce'] as String? ?? '',
      isown: json['isown'] as bool? ?? false,
      isuse: json['isuse'] as bool? ?? false,
      tipsmsg: json['tipsmsg'] as String? ?? '',
      showimg: json['showimg'] as String?,
      url: json['url'] as String?,
      newwelfare: json['newwelfare'] as bool? ?? false,
      sort: json['sort'] as int? ?? 0,
    );
  }
}
