import 'package:decimal/decimal.dart';

/// 我的优惠券状态。
///
/// 对齐接口文档 POST /api/promotion/getcoupongrouplist：
///   1 有效 / 2 已使用 / 3 已过期 / 4 转赠中。
enum CouponGroupStatus {
  valid(1, '未使用'),
  used(2, '已使用'),
  expired(3, '已过期'),
  transferring(4, '转赠中');

  const CouponGroupStatus(this.apiValue, this.label);

  final int apiValue;
  final String label;

  static CouponGroupStatus fromApiValue(int value) {
    return CouponGroupStatus.values.firstWhere((status) => status.apiValue == value, orElse: () => CouponGroupStatus.valid);
  }
}

/// 优惠券分组列表中的单张优惠券。
///
/// 字段来自接口文档的 `coupons[]`，不额外虚构字段。
class CouponGroupInfo {
  final String couponName;
  final int couponTypeId;
  final int storeId;
  final String storeName;
  final int discount;
  final Decimal money;
  final Decimal limitLowAmount;
  final bool limitProduct;
  final List<int> productIdList;
  final DateTime? startTime;
  final DateTime? endTime;
  final CouponGroupStatus status;
  final bool available;
  final bool zjCoupon;
  final int count;
  final String shareGroup;
  final bool canTransfer;

  const CouponGroupInfo({
    required this.couponName,
    this.couponTypeId = 0,
    this.storeId = 0,
    this.storeName = '',
    this.discount = 0,
    required this.money,
    required this.limitLowAmount,
    this.limitProduct = false,
    this.productIdList = const [],
    this.startTime,
    this.endTime,
    this.status = CouponGroupStatus.valid,
    this.available = false,
    this.zjCoupon = false,
    this.count = 0,
    this.shareGroup = '',
    this.canTransfer = false,
  });

  factory CouponGroupInfo.fromJson(Map<String, dynamic> json) {
    return CouponGroupInfo(
      couponName: _asString(json['couponname']),
      couponTypeId: _asInt(json['coupontypeid']),
      storeId: _asInt(json['storeid']),
      storeName: _asString(json['storename']),
      discount: _asInt(json['discount']),
      money: _asDecimal(json['money']),
      limitLowAmount: _asDecimal(json['limitlowamount']),
      limitProduct: _asBool(json['limitproduct']),
      productIdList: _asIntList(json['productidlist']),
      startTime: _asDateTime(json['starttime']),
      endTime: _asDateTime(json['endtime']),
      status: CouponGroupStatus.fromApiValue(_asInt(json['status'])),
      available: _asBool(json['available']),
      zjCoupon: _asBool(json['zjcoupon']),
      count: _asInt(json['count']),
      shareGroup: _asString(json['sharegroup']),
      canTransfer: _asBool(json['cantransfer']),
    );
  }
}

/// 优惠券分组列表响应。
class CouponGroupListResult {
  final List<CouponGroupInfo> coupons;
  final int totalCount;
  final String? dataTag;

  const CouponGroupListResult({required this.coupons, required this.totalCount, this.dataTag});

  factory CouponGroupListResult.fromJson(Map<String, dynamic> json) {
    final rawCoupons = json['coupons'];
    final coupons = rawCoupons is List
        ? rawCoupons.whereType<Map>().map((item) => CouponGroupInfo.fromJson(Map<String, dynamic>.from(item))).toList(growable: false)
        : const <CouponGroupInfo>[];

    return CouponGroupListResult(coupons: coupons, totalCount: _asInt(json['totalcount']), dataTag: json['datatag']?.toString());
  }
}

String _asString(dynamic value) => value?.toString() ?? '';

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}

Decimal _asDecimal(dynamic value) {
  if (value is Decimal) return value;
  if (value == null) return Decimal.zero;
  return Decimal.tryParse(value.toString()) ?? Decimal.zero;
}

List<int> _asIntList(dynamic value) {
  if (value is! List) return const [];
  return value.map(_asInt).where((item) => item != 0).toList(growable: false);
}

DateTime? _asDateTime(dynamic value) {
  if (value is DateTime) return value;
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : DateTime.tryParse(text);
}
