import 'dart:typed_data';

import '../../data/models/member_authority_model.dart';
import '../../data/models/available_welfare_model.dart';
import '../../data/models/cash_coupon_model.dart';
import '../../data/models/coupon_group_model.dart';
import '../../data/models/service_coupon_model.dart';
import '../../data/models/member_rank_models.dart';
import '../../../../core/network/api_response.dart';

/// 会员仓库接口
abstract class MemberRepository {
  /// 获取会员信息
  Future<ApiResponse<MemberInfo>> getMemberInfo();

  /// 获取会员等级权益
  Future<ApiResponse<MemberLevelBenefits>> getLevelBenefits(int level);

  /// 获取会员等级列表（真实接口：POST /api/sys/app/getranklist）
  ///
  /// 返回全部等级的定义（等级 id / 名称 / 积分区间），用于会员详情页等级页签。
  Future<ApiResponse<GetRankListResp>> getRankList();

  /// 获取指定等级的权益明细（真实接口：POST /api/sys/app/getrankdetail）
  ///
  /// [level] 为等级 id（getranklist 返回的 userrid）。
  /// 返回该等级的月度权益产品与权益列表（普通权益 / 月度权益 / 生日赠礼）。
  Future<ApiResponse<GetRankDetailResp>> getRankDetail({required int level});

  /// 领取用户月度权益或生日赠礼
  Future<ApiResponse<ReceiveUserServiceResult>> receiveUserService({required int serviceId});

  /// 补充/修改用户个人资料。
  Future<ApiResponse<CompleteUserInfoResult>> completeUserInfo({required String username, required int gender, required DateTime birthday});

  /// 更换当前用户头像（真实接口：POST /api/sys/changeuseravatar）。
  Future<ApiResponse<void>> changeUserAvatar({required Uint8List buffer, required String ext});

  /// 获取会员权益权限（真实接口：POST /api/sys/v2/getmemberauthority）
  Future<ApiResponse<MemberAuthorityModel>> getMemberAuthority({required int level});

  /// 获取优惠券列表
  Future<ApiResponse<CouponListResult>> getCoupons({required int page, required int pageSize, CouponStatus? status});

  /// 获取我的优惠券分组列表（真实接口：POST /api/promotion/getcoupongrouplist）
  Future<ApiResponse<CouponGroupListResult>> getCouponGroupList({required CouponGroupStatus status});

  /// 获取待解锁红包列表（真实接口：POST /api/promotion/getcashcouponlist）
  Future<ApiResponse<CashCouponListResult>> getCashCouponList({required CashCouponStatus status, required int pageIndex, required int pageSize});

  /// 获取待解锁红包详情（真实接口：POST /api/promotion/getcashcoupondetail）
  Future<ApiResponse<CashCouponDetailResult>> getCashCouponDetail({required String couponSn});

  /// 获取可用福利列表（真实接口：POST /api/promotion/availablewelfarelist）
  Future<ApiResponse<AvailableWelfareListResult>> getAvailableWelfareList({required bool cardOnly});

  /// 获取服务券列表（真实接口：POST /api/promotion/getservicecouponlist）
  Future<ApiResponse<ServiceCouponListResult>> getServiceCouponList({required ServiceCouponStatus status, bool selfSetOnly = false});

  /// 刷新服务券兑换信息（真实接口：POST /api/promotion/v2/refreshservicecouponinfov2）
  Future<ApiResponse<ServiceCouponInfoResult>> refreshServiceCouponInfoV2({required int couponTypeId, required int count, String? preferCouponSn});

  /// 转赠服务券（真实接口：POST /api/promotion/giveservicecoupon）
  Future<ApiResponse<void>> giveServiceCoupon({required int serviceCouponId, required int count});

  /// 取消转赠服务券（真实接口：POST /api/promotion/giveservicecouponreovoke）
  Future<ApiResponse<void>> revokeServiceCoupon({required int serviceCouponId, required String shareGroup});

  /// 领取优惠券
  Future<ApiResponse<void>> claimCoupon(String couponTemplateId);

  /// 获取积分账户
  Future<ApiResponse<PointsAccount>> getPointsAccount();

  /// 获取积分流水（分页）
  Future<ApiResponse<PointsLogResult>> getPointsLogs({required int page, required int pageSize, PointsLogType? type});

  /// 获取积分规则
  Future<ApiResponse<String>> getPointsRules();

  /// 获取收支明细
  Future<ApiResponse<StatementResult>> getStatements({required int page, required int pageSize, StatementType? type});

  /// 获取收货地址列表
  Future<ApiResponse<List<MemberAddress>>> getAddresses({int addressId = 0});

  /// 新增/编辑收货地址
  Future<ApiResponse<MemberAddress>> saveAddress(MemberAddress address);

  /// 删除收货地址
  Future<ApiResponse<void>> deleteAddress(String addressId);

  /// 设置默认地址
  Future<ApiResponse<void>> setDefaultAddress(String addressId);

  /// 获取客服信息
  Future<ApiResponse<CustomerServiceInfo>> getCustomerService();
}

/// 领取用户权益接口结果
class ReceiveUserServiceResult {
  /// 用户已领取的权益 id，不是 serviceId
  final int userServiceId;

  /// 是否为重复领取
  final bool isDuplicate;

  const ReceiveUserServiceResult({required this.userServiceId, required this.isDuplicate});

  factory ReceiveUserServiceResult.fromJson(Map<String, dynamic> json) {
    final userServiceId = json['userserviceid'];
    final duplicate = json['isdup'];
    return ReceiveUserServiceResult(
      userServiceId: userServiceId is num ? userServiceId.toInt() : int.tryParse('$userServiceId') ?? 0,
      isDuplicate: duplicate is bool ? duplicate : duplicate == 1 || duplicate == '1' || duplicate == 'true',
    );
  }
}

/// 用户信息补充接口响应。
class CompleteUserInfoResult {
  final int farmEnergyNum;
  final String? dataTag;

  const CompleteUserInfoResult({this.farmEnergyNum = 0, this.dataTag});

  factory CompleteUserInfoResult.fromJson(Map<String, dynamic> json) {
    final energy = json['farmenergynum'];
    return CompleteUserInfoResult(farmEnergyNum: energy is num ? energy.toInt() : int.tryParse('$energy') ?? 0, dataTag: json['datatag'] as String?);
  }
}

/// 会员信息
class MemberInfo {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final int memberLevel;
  final String levelName;
  final int growthValue;
  final int nextLevelGrowthValue;
  final int points;
  final int availableCoupons;
  final bool hasHousekeeper;
  final String? housekeeperName;
  final String? housekeeperPhone;

  const MemberInfo.empty()
    : id = '',
      nickname = '',
      avatarUrl = null,
      memberLevel = 0,
      levelName = '未登录',
      growthValue = 0,
      nextLevelGrowthValue = 0,
      points = 0,
      availableCoupons = 0,
      hasHousekeeper = false,
      housekeeperName = null,
      housekeeperPhone = null;

  const MemberInfo({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.memberLevel,
    required this.levelName,
    required this.growthValue,
    required this.nextLevelGrowthValue,
    required this.points,
    required this.availableCoupons,
    required this.hasHousekeeper,
    this.housekeeperName,
    this.housekeeperPhone,
  });
}

/// 会员等级权益
class MemberLevelBenefits {
  final int level;
  final String name;
  final List<String> benefits;
  final String? description;

  const MemberLevelBenefits({required this.level, required this.name, required this.benefits, this.description});
}

/// 优惠券列表结果
class CouponListResult {
  final List<Coupon> coupons;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const CouponListResult({required this.coupons, required this.total, required this.page, required this.pageSize, required this.hasMore});
}

/// 优惠券实体
class Coupon {
  final String id;
  final String templateId;
  final String name;
  final String description;
  final CouponType type;
  final int discountCents; // 满减金额或折扣百分比
  final int minOrderCents; // 门槛
  final DateTime startTime;
  final DateTime endTime;
  final CouponStatus status;
  final String? applicableProducts; // 适用商品范围
  final int? maxUseCount;

  const Coupon({
    required this.id,
    required this.templateId,
    required this.name,
    required this.description,
    required this.type,
    required this.discountCents,
    required this.minOrderCents,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.applicableProducts,
    this.maxUseCount,
  });
}

enum CouponType {
  discount('满减券'),
  percent('折扣券'),
  shipping('包邮券'),
  gift('赠品券');

  const CouponType(this.label);
  final String label;
}

enum CouponStatus {
  available('可使用'),
  used('已使用'),
  expired('已过期'),
  locked('待激活');

  const CouponStatus(this.label);
  final String label;
}

/// 积分账户
class PointsAccount {
  final int totalPoints;
  final int availablePoints;
  final int frozenPoints;
  final int expiringPoints;
  final DateTime? expiringDate;
  final int todayEarned;
  final int totalEarned;

  const PointsAccount({
    required this.totalPoints,
    required this.availablePoints,
    required this.frozenPoints,
    required this.expiringPoints,
    this.expiringDate,
    required this.todayEarned,
    required this.totalEarned,
  });
}

/// 积分流水结果
class PointsLogResult {
  final List<PointsLog> logs;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PointsLogResult({required this.logs, required this.total, required this.page, required this.pageSize, required this.hasMore});
}

/// 积分流水项
class PointsLog {
  final String id;
  final PointsLogType type;
  final int points;
  final int balanceAfter;
  final String description;
  final DateTime createTime;
  final String? relatedOrderNo;

  const PointsLog({
    required this.id,
    required this.type,
    required this.points,
    required this.balanceAfter,
    required this.description,
    required this.createTime,
    this.relatedOrderNo,
  });
}

enum PointsLogType {
  earn('获得'),
  spend('消费'),
  expire('过期'),
  freeze('冻结'),
  unfreeze('解冻');

  const PointsLogType(this.label);
  final String label;
}

/// 收支明细结果
class StatementResult {
  final List<StatementItem> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const StatementResult({required this.items, required this.total, required this.page, required this.pageSize, required this.hasMore});
}

class StatementItem {
  final String id;
  final StatementType type;
  final int amountCents;
  final int balanceCents;
  final String description;
  final DateTime createTime;
  final String? relatedOrderNo;

  const StatementItem({
    required this.id,
    required this.type,
    required this.amountCents,
    required this.balanceCents,
    required this.description,
    required this.createTime,
    this.relatedOrderNo,
  });
}

enum StatementType {
  income('收入'),
  expense('支出'),
  refund('退款'),
  reward('奖励');

  const StatementType(this.label);
  final String label;
}

/// 会员收货地址
class MemberAddress {
  final String? id;
  final int? areaId;
  final String name;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String detail;
  final bool isDefault;
  final String? label; // 家/公司

  const MemberAddress({
    this.id,
    this.areaId,
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    this.isDefault = false,
    this.label,
  });

  /// 将用户地址列表接口返回的 AddressInfo 映射为领域地址实体。
  ///
  /// 接口字段中默认地址字段拼写为 `isdefult`，同时兼容布尔值、数字和字符串。
  factory MemberAddress.fromApiJson(Map<dynamic, dynamic> json) {
    String stringValue(String key) => json[key]?.toString() ?? '';
    final rawId = json['id'];
    final rawDefault = json['isdefult'];
    final isDefault = rawDefault is bool
        ? rawDefault
        : rawDefault is num
        ? rawDefault != 0
        : rawDefault?.toString().toLowerCase() == 'true' || rawDefault?.toString() == '1';
    final phone = stringValue('phone').isNotEmpty ? stringValue('phone') : stringValue('mobile');
    return MemberAddress(
      id: rawId?.toString(),
      areaId: _intOrNull(json['regionid']),
      name: stringValue('consignee'),
      phone: phone,
      province: stringValue('provincename'),
      city: stringValue('cityname'),
      district: stringValue('countyname'),
      detail: stringValue('address'),
      isDefault: isDefault,
    );
  }

  static int? _intOrNull(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String get fullAddress => '$province$city$district$detail';

  MemberAddress copyWith({
    String? id,
    int? areaId,
    String? name,
    String? phone,
    String? province,
    String? city,
    String? district,
    String? detail,
    bool? isDefault,
    String? label,
  }) {
    return MemberAddress(
      id: id ?? this.id,
      areaId: areaId ?? this.areaId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      detail: detail ?? this.detail,
      isDefault: isDefault ?? this.isDefault,
      label: label ?? this.label,
    );
  }
}

/// 客服信息
class CustomerServiceInfo {
  final String phone;
  final String onlineUrl;
  final String workTime;
  final String? qrCodeUrl;

  const CustomerServiceInfo({required this.phone, required this.onlineUrl, required this.workTime, this.qrCodeUrl});
}
