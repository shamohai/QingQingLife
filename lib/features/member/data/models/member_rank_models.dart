/// 会员等级 / 等级权益明细接口响应 Model
///
/// 对齐后端接口文档：
///   - POST /api/sys/app/getranklist   获取等级列表
///     → [GetRankListResp] { ranks: [RankBaseInfo], datatag }
///   - POST /api/sys/app/getrankdetail 获取等级对应的权益明细（请求 { userrid })
///     → [GetRankDetailResp] { monthlyproductlist, rankbaseinfo, services, datatag }
///
/// 注：请求公共参数 meta / authtoken 由拦截器统一注入，业务层无需传。
library;

/// 服务组别（services[].group），后端枚举字符串
abstract final class ServiceGroup {
  /// 普通权益
  static const String general = 'GENERAL';

  /// 月度权益
  static const String monthly = 'MONTHLY';

  /// 生日赠礼
  static const String birthday = 'BIRTHDAY';
}

/// 权益实现类型（services[].instancetype），后端枚举字符串
///
/// 用于判断权益后续跳转 / 下单方式。
abstract final class ServiceInstanceType {
  /// 服务券
  static const String serviceCoupon = 'ServiceCoupon';

  /// 产品订单
  static const String products = 'Products';

  /// 红包分享
  static const String cashCouponShare = 'CashCouponShare';

  /// 权益商城
  static const String shareCart = 'ShareCart';
}

/// 安全地把后端字段转成 int（后端可能返回 int / num / 数字字符串 / null）
int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// 安全地把后端字段转成 bool（后端可能返回 bool / 0|1 / 字符串 / null）
bool _asBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.toLowerCase();
    return v == 'true' || v == '1';
  }
  return false;
}

/// 等级基本信息（getranklist / getrankdetail 通用）
class RankBaseInfo {
  /// 等级 id（MemberLevel）：用于匹配用户当前等级，也是 getrankdetail 的入参
  final int userrid;

  /// 等级名称（如 人之德 / 顾问级）
  final String userridname;

  /// 当前等级的过期日期（原始字符串，后端为 DateTime 序列化）
  final String? expiredate;

  /// 当前等级的起始积分（即达到该等级所需的成长值/积分门槛）
  final int currentrankstart;

  /// 当前等级的结束积分；等于 0 表示无上限
  final int currentrankend;

  /// 等级图标地址
  final String iconUrl;

  const RankBaseInfo({
    required this.userrid,
    required this.userridname,
    this.expiredate,
    this.currentrankstart = 0,
    this.currentrankend = 0,
    this.iconUrl = '',
  });

  /// 过期日期（解析失败返回 null）
  DateTime? get expireDate => expiredate == null ? null : DateTime.tryParse(expiredate!);

  factory RankBaseInfo.fromJson(Map<String, dynamic> json) {
    return RankBaseInfo(
      userrid: _asInt(json['userrid']),
      userridname: (json['userridname'] as String?) ?? '',
      expiredate: json['expiredate'] as String?,
      currentrankstart: _asInt(json['currentrankstart']),
      currentrankend: _asInt(json['currentrankend']),
      iconUrl: (json['iconurl'] as String?)?.trim() ?? '',
    );
  }
}

/// 获取等级列表 响应
///
/// 接口：POST /api/sys/app/getranklist
class GetRankListResp {
  /// 等级列表
  final List<RankBaseInfo> ranks;

  /// 数据版本
  final String? datatag;

  const GetRankListResp({required this.ranks, this.datatag});

  factory GetRankListResp.fromJson(Map<String, dynamic> json) {
    return GetRankListResp(
      ranks: (json['ranks'] as List<dynamic>?)?.map((e) => RankBaseInfo.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      datatag: json['datatag'] as String?,
    );
  }
}

/// 服务产品项（monthlyproductlist / bindinfo.bindproductlist）
class ServiceProductItem {
  /// 服务 id
  final int serviceid;

  /// 服务编码
  final String servicecode;

  /// 服务名称
  final String productname;

  /// 服务描述
  final String servicedescr;

  /// 是否已领取
  final bool isreceived;

  /// 领取时间
  final String? receiveddate;

  /// 产品类型（ProductType，普通实物 / 百礼汇等）
  final int producttype;

  /// 用户权益 id；> 0 表示已领取
  final int userserviceid;

  /// 百礼汇产品类型（BaiLiHuiProductType）
  final int bailihuitype;

  /// 产品 id
  final int pid;

  /// 产品图
  final String? productimg;

  const ServiceProductItem({
    required this.serviceid,
    this.servicecode = '',
    this.productname = '',
    this.servicedescr = '',
    this.isreceived = false,
    this.receiveddate,
    this.producttype = 0,
    this.userserviceid = 0,
    this.bailihuitype = 0,
    this.pid = 0,
    this.productimg,
  });

  factory ServiceProductItem.fromJson(Map<String, dynamic> json) {
    return ServiceProductItem(
      serviceid: _asInt(json['serviceid']),
      servicecode: (json['servicecode'] as String?) ?? '',
      productname: (json['productname'] as String?) ?? '',
      servicedescr: (json['servicedescr'] as String?) ?? '',
      isreceived: _asBool(json['isreceived']),
      receiveddate: json['receiveddate'] as String?,
      producttype: _asInt(json['producttype']),
      userserviceid: _asInt(json['userserviceid']),
      bailihuitype: _asInt(json['bailihuitype']),
      pid: _asInt(json['pid']),
      productimg: json['productimg'] as String?,
    );
  }
}

/// 权益绑定的服务券信息（bindinfo.bindservicecouponinfo）
class ServiceBindServiceCouponInfo {
  /// 服务券配置 id
  final int servicecoupontypeid;

  /// 用户已领取的服务券 id，未领取则为 null
  final int? servicecouponid;

  final String description;
  final String? headimgurl;
  final String name;

  const ServiceBindServiceCouponInfo({this.servicecoupontypeid = 0, this.servicecouponid, this.description = '', this.headimgurl, this.name = ''});

  factory ServiceBindServiceCouponInfo.fromJson(Map<String, dynamic> json) {
    return ServiceBindServiceCouponInfo(
      servicecoupontypeid: _asInt(json['servicecoupontypeid']),
      servicecouponid: json['servicecouponid'] == null ? null : _asInt(json['servicecouponid']),
      description: (json['description'] as String?) ?? '',
      headimgurl: json['headimgurl'] as String?,
      name: (json['name'] as String?) ?? '',
    );
  }
}

/// 权益绑定的权益商城信息（bindinfo.bindsharecartinfo）
class ServiceBindShareCart {
  /// 权益商城模板套餐 id
  final int sharecarttemplateid;

  /// 用户已选购的购物车信息，未选购则为 null
  final int? sharecartid;

  final String description;
  final String? headimgurl;
  final String name;

  const ServiceBindShareCart({this.sharecarttemplateid = 0, this.sharecartid, this.description = '', this.headimgurl, this.name = ''});

  factory ServiceBindShareCart.fromJson(Map<String, dynamic> json) {
    return ServiceBindShareCart(
      sharecarttemplateid: _asInt(json['sharecarttemplateid']),
      sharecartid: json['sharecartid'] == null ? null : _asInt(json['sharecartid']),
      description: (json['description'] as String?) ?? '',
      headimgurl: json['headimgurl'] as String?,
      name: (json['name'] as String?) ?? '',
    );
  }
}

/// 权益绑定的待解锁红包信息（bindinfo.bindcashcouponinfo）
class ServiceBindCashCoupon {
  /// 待解锁红包配置 id
  final int cashcouponconfigid;

  final String description;
  final String? headimgurl;
  final String name;

  const ServiceBindCashCoupon({this.cashcouponconfigid = 0, this.description = '', this.headimgurl, this.name = ''});

  factory ServiceBindCashCoupon.fromJson(Map<String, dynamic> json) {
    return ServiceBindCashCoupon(
      cashcouponconfigid: _asInt(json['cashcouponconfigid']),
      description: (json['description'] as String?) ?? '',
      headimgurl: json['headimgurl'] as String?,
      name: (json['name'] as String?) ?? '',
    );
  }
}

/// 权益绑定信息（services[].bindinfo）
///
/// 有值表示用户已拥有该权益；为空表示可能有资格但未领取，或没有资格。
class ServiceBindInfo {
  /// 绑定的产品列表（未绑定为 null）
  final List<ServiceProductItem>? bindproductlist;

  /// 绑定的服务券信息（未绑定为 null）
  final ServiceBindServiceCouponInfo? bindservicecouponinfo;

  /// 绑定的权益商城信息（未绑定为 null）
  final ServiceBindShareCart? bindsharecartinfo;

  /// 绑定的待解锁红包信息（未绑定为 null）
  final ServiceBindCashCoupon? bindcashcouponinfo;

  const ServiceBindInfo({this.bindproductlist, this.bindservicecouponinfo, this.bindsharecartinfo, this.bindcashcouponinfo});

  factory ServiceBindInfo.fromJson(Map<String, dynamic> json) {
    return ServiceBindInfo(
      bindproductlist: (json['bindproductlist'] as List<dynamic>?)?.map((e) => ServiceProductItem.fromJson(e as Map<String, dynamic>)).toList(),
      bindservicecouponinfo: json['bindservicecouponinfo'] == null
          ? null
          : ServiceBindServiceCouponInfo.fromJson(json['bindservicecouponinfo'] as Map<String, dynamic>),
      bindsharecartinfo: json['bindsharecartinfo'] == null ? null : ServiceBindShareCart.fromJson(json['bindsharecartinfo'] as Map<String, dynamic>),
      bindcashcouponinfo: json['bindcashcouponinfo'] == null ? null : ServiceBindCashCoupon.fromJson(json['bindcashcouponinfo'] as Map<String, dynamic>),
    );
  }
}

/// 等级权益项（getrankdetail 响应 services[]）
class SysServiceItem {
  /// 服务 id
  final int serviceid;

  /// 服务编码
  final String servicecode;

  /// 服务名称
  final String servicename;

  /// 用户已领取的权益 id；未领取时为 null。
  final int? userserviceid;

  /// 权益实现类型，见 [ServiceInstanceType]
  final String instancetype;

  /// 服务组别，见 [ServiceGroup]
  final String group;

  /// 服务图标
  final String? icon;

  /// 用户是否已拥有此权益
  final bool hasowned;

  /// 用户是否已领取此权益
  final bool hasreceived;

  /// 权益是否已核销
  final bool settlemented;

  /// 用户权益绑定信息
  final ServiceBindInfo? bindinfo;

  const SysServiceItem({
    required this.serviceid,
    this.servicecode = '',
    this.servicename = '',
    this.userserviceid,
    this.instancetype = '',
    this.group = '',
    this.icon,
    this.hasowned = false,
    this.hasreceived = false,
    this.settlemented = false,
    this.bindinfo,
  });

  /// 权益说明：优先取绑定产品描述，其次取服务券 / 权益商城 / 红包描述
  String get description {
    final info = bindinfo;
    final productList = info?.bindproductlist;
    if (productList != null && productList.isNotEmpty) return productList.first.servicedescr;
    if (info?.bindservicecouponinfo != null) return info!.bindservicecouponinfo!.description;
    if (info?.bindsharecartinfo != null) return info!.bindsharecartinfo!.description;
    if (info?.bindcashcouponinfo != null) return info!.bindcashcouponinfo!.description;
    return '';
  }

  factory SysServiceItem.fromJson(Map<String, dynamic> json) {
    return SysServiceItem(
      serviceid: _asInt(json['serviceid']),
      servicecode: (json['servicecode'] as String?) ?? '',
      servicename: (json['servicename'] as String?) ?? '',
      userserviceid: json['userserviceid'] == null ? null : _asInt(json['userserviceid']),
      instancetype: (json['instancetype'] as String?) ?? '',
      group: (json['group'] as String?) ?? '',
      icon: json['icon'] as String?,
      hasowned: _asBool(json['hasowned']),
      hasreceived: _asBool(json['hasreceived']),
      settlemented: _asBool(json['settlemented']),
      bindinfo: json['bindinfo'] == null ? null : ServiceBindInfo.fromJson(json['bindinfo'] as Map<String, dynamic>),
    );
  }

  SysServiceItem copyWith({int? userserviceid, bool? hasowned, bool? hasreceived, ServiceBindInfo? bindinfo}) {
    return SysServiceItem(
      serviceid: serviceid,
      servicecode: servicecode,
      servicename: servicename,
      userserviceid: userserviceid ?? this.userserviceid,
      instancetype: instancetype,
      group: group,
      icon: icon,
      hasowned: hasowned ?? this.hasowned,
      hasreceived: hasreceived ?? this.hasreceived,
      settlemented: settlemented,
      bindinfo: bindinfo ?? this.bindinfo,
    );
  }
}

/// 获取等级对应权益明细 响应
///
/// 接口：POST /api/sys/app/getrankdetail
class GetRankDetailResp {
  /// 月度权益 id；没有月度权益时为 null
  final int? monthlyserviceid;

  /// 用户已领取的月度权益 id；未领取时为 null
  final int? monthlyuserserviceid;

  /// 月度权益产品（与 services.bindinfo.bindproductlist 相同）
  final List<ServiceProductItem> monthlyproductlist;

  /// 等级基本信息
  final RankBaseInfo? rankbaseinfo;

  /// 权益列表（普通权益 / 月度权益 / 生日赠礼，按 group 区分）
  final List<SysServiceItem> services;

  /// 数据版本
  final String? datatag;

  const GetRankDetailResp({
    this.monthlyserviceid,
    this.monthlyuserserviceid,
    this.monthlyproductlist = const [],
    this.rankbaseinfo,
    this.services = const [],
    this.datatag,
  });

  factory GetRankDetailResp.fromJson(Map<String, dynamic> json) {
    return GetRankDetailResp(
      monthlyserviceid: json['monthlyserviceid'] == null ? null : _asInt(json['monthlyserviceid']),
      monthlyuserserviceid: json['monthlyuserserviceid'] == null ? null : _asInt(json['monthlyuserserviceid']),
      monthlyproductlist:
          (json['monthlyproductlist'] as List<dynamic>?)?.map((e) => ServiceProductItem.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      rankbaseinfo: json['rankbaseinfo'] == null ? null : RankBaseInfo.fromJson(json['rankbaseinfo'] as Map<String, dynamic>),
      services: (json['services'] as List<dynamic>?)?.map((e) => SysServiceItem.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      datatag: json['datatag'] as String?,
    );
  }

  GetRankDetailResp copyWith({int? monthlyuserserviceid, List<SysServiceItem>? services}) {
    return GetRankDetailResp(
      monthlyserviceid: monthlyserviceid,
      monthlyuserserviceid: monthlyuserserviceid ?? this.monthlyuserserviceid,
      monthlyproductlist: monthlyproductlist,
      rankbaseinfo: rankbaseinfo,
      services: services ?? this.services,
      datatag: datatag,
    );
  }
}
