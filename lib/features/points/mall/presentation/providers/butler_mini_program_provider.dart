import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/providers.dart';

/// 专属管家服务配置 (VIP)
class ButlerVipInfo {
  /// 服务标题
  final String title;

  /// 企微二维码图片地址
  final String workwxqrimg;

  /// 企微客服的小程序路径（如 /pages/index/index?rid=123）
  final String workwxmppath;

  /// 联系电话
  final String tel;

  /// 电话名称
  final String telname;

  /// 服务描述（如：服务范围、时间）
  final String servicedescr;

  const ButlerVipInfo({
    this.title = '',
    this.workwxqrimg = '',
    this.workwxmppath = '',
    this.tel = '',
    this.telname = '',
    this.servicedescr = '',
  });

  factory ButlerVipInfo.fromJson(Map<String, dynamic> json) {
    return ButlerVipInfo(
      title: (json['title'] ?? '').toString(),
      workwxqrimg: (json['workwxqrimg'] ?? '').toString(),
      workwxmppath: (json['workwxmppath'] ?? '').toString(),
      tel: (json['tel'] ?? '').toString(),
      telname: (json['telname'] ?? '').toString(),
      servicedescr: (json['servicedescr'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'workwxqrimg': workwxqrimg,
        'workwxmppath': workwxmppath,
        'tel': tel,
        'telname': telname,
        'servicedescr': servicedescr,
      };
}

/// 普通用户服务配置 (Default / 联系客服)
class ButlerDefaultInfo {
  /// 普通客户微信客服 url
  final String wxcustomerserviceurl;

  /// 企微的 CorpId（固定值：ww207c2d0f4b9efa02，微信客服使用）
  final String workwxcorpid;

  /// 服务描述（如：服务范围、时间）
  final String servicedescr;

  /// 备用电话（拉起微信客服失败时提示用户拨打）
  final String fallbacktel;

  const ButlerDefaultInfo({
    this.wxcustomerserviceurl = '',
    this.workwxcorpid = '',
    this.servicedescr = '',
    this.fallbacktel = '',
  });

  factory ButlerDefaultInfo.fromJson(Map<String, dynamic> json) {
    return ButlerDefaultInfo(
      wxcustomerserviceurl: (json['wxcustomerserviceurl'] ?? '').toString(),
      workwxcorpid: (json['workwxcorpid'] ?? '').toString(),
      servicedescr: (json['servicedescr'] ?? '').toString(),
      fallbacktel: (json['fallbacktel'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'wxcustomerserviceurl': wxcustomerserviceurl,
        'workwxcorpid': workwxcorpid,
        'servicedescr': servicedescr,
        'fallbacktel': fallbacktel,
      };
}

/// 客户经理/管家服务信息配置
/// 接口：POST /api/sys/app/getcustomermanagerinfo
class ButlerMiniProgramInfo {
  /// 专属管家服务配置 (VIP)
  final ButlerVipInfo? vip;

  /// 普通用户服务配置 (Default)
  final ButlerDefaultInfo? defaultConfig;

  /// 数据版本标识
  final String datatag;

  /// 兼容旧代码：直接获取专属管家小程序路径
  String get workwxmppath => vip?.workwxmppath ?? '';

  const ButlerMiniProgramInfo({
    this.vip,
    this.defaultConfig,
    this.datatag = '',
  });

  factory ButlerMiniProgramInfo.fromJson(Map<String, dynamic> json) {
    final info = json['info'];
    final infoJson = info is Map ? Map<String, dynamic>.from(info) : json;

    final vipData = infoJson['vip'];
    final vipInfo = vipData is Map
        ? ButlerVipInfo.fromJson(Map<String, dynamic>.from(vipData))
        : (infoJson.containsKey('workwxmppath')
            ? ButlerVipInfo(
                workwxmppath: (infoJson['workwxmppath'] ?? '').toString(),
                title: (infoJson['title'] ?? '').toString(),
                workwxqrimg: (infoJson['workwxqrimg'] ?? '').toString(),
                tel: (infoJson['tel'] ?? '').toString(),
                telname: (infoJson['telname'] ?? '').toString(),
                servicedescr: (infoJson['servicedescr'] ?? '').toString(),
              )
            : null);

    final defaultData = infoJson['default'];
    final defaultInfo = defaultData is Map
        ? ButlerDefaultInfo.fromJson(Map<String, dynamic>.from(defaultData))
        : null;

    final datatag = (json['datatag'] ?? infoJson['datatag'] ?? '').toString();

    return ButlerMiniProgramInfo(
      vip: vipInfo,
      defaultConfig: defaultInfo,
      datatag: datatag,
    );
  }

  Map<String, dynamic> toJson() => {
        if (vip != null) 'vip': vip!.toJson(),
        if (defaultConfig != null) 'default': defaultConfig!.toJson(),
        'datatag': datatag,
      };
}

final butlerMiniProgramInfoProvider = FutureProvider<ButlerMiniProgramInfo?>((ref) async {
  final response = await ref
      .read(apiClientProvider)
      .post<ButlerMiniProgramInfo>(
        '/api/sys/app/getcustomermanagerinfo',
        data: const <String, dynamic>{},
        fromJson: (dynamic json) => ButlerMiniProgramInfo.fromJson(Map<String, dynamic>.from(json as Map)),
      );
  if (!response.success) return null;
  return response.data;
});
