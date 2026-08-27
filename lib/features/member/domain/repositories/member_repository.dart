import '../../../../core/network/api_response.dart';

/// 会员仓库接口
abstract class MemberRepository {
  /// 获取会员信息
  Future<ApiResponse<MemberInfo>> getMemberInfo();

  /// 获取会员等级权益
  Future<ApiResponse<MemberLevelBenefits>> getLevelBenefits(int level);

  /// 获取优惠券列表
  Future<ApiResponse<CouponListResult>> getCoupons({required int page, required int pageSize, CouponStatus? status});

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
  Future<ApiResponse<List<MemberAddress>>> getAddresses();

  /// 新增/编辑收货地址
  Future<ApiResponse<MemberAddress>> saveAddress(MemberAddress address);

  /// 删除收货地址
  Future<ApiResponse<void>> deleteAddress(String addressId);

  /// 设置默认地址
  Future<ApiResponse<void>> setDefaultAddress(String addressId);

  /// 获取客服信息
  Future<ApiResponse<CustomerServiceInfo>> getCustomerService();
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

  const CouponListResult({
    required this.coupons,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
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

  const PointsLogResult({
    required this.logs,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
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

  const StatementResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
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
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    this.isDefault = false,
    this.label,
  });

  String get fullAddress => '$province$city$district$detail';

  MemberAddress copyWith({
    String? id,
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
