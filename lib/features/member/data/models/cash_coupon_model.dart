import 'package:decimal/decimal.dart';

import 'coupon_group_model.dart';

/// 待解锁红包状态。
enum CashCouponStatus {
  valid(1, '待使用'),
  used(2, '已使用'),
  expired(3, '已过期');

  const CashCouponStatus(this.apiValue, this.label);

  final int apiValue;
  final String label;

  static CashCouponStatus fromApiValue(int value) {
    return CashCouponStatus.values.firstWhere((status) => status.apiValue == value, orElse: () => CashCouponStatus.valid);
  }
}

/// 待解锁红包列表与详情共有字段。
class CashCouponInfo {
  final int leftScanCount;
  final CashCouponStatus status;
  final bool allowTransfer;
  final int cashCouponConfigId;
  final int cashCouponId;
  final int couponCount;
  final String couponName;
  final String couponSn;
  final DateTime? endTime;
  final Decimal money;
  final int productId;
  final String productName;
  final Decimal rebate;
  final String remark;
  final String shareGroup;
  final DateTime? startTime;

  /// 详情接口扩展字段。
  final int scanMarketCodeNth;
  final int scanedCount;
  final String requirement;

  const CashCouponInfo({
    this.leftScanCount = 0,
    this.status = CashCouponStatus.valid,
    this.allowTransfer = false,
    this.cashCouponConfigId = 0,
    this.cashCouponId = 0,
    this.couponCount = 0,
    this.couponName = '',
    this.couponSn = '',
    this.endTime,
    required this.money,
    this.productId = 0,
    this.productName = '',
    required this.rebate,
    this.remark = '',
    this.shareGroup = '',
    this.startTime,
    this.scanMarketCodeNth = 0,
    this.scanedCount = 0,
    this.requirement = '',
  });

  factory CashCouponInfo.fromJson(Map<String, dynamic> json) {
    return CashCouponInfo(
      leftScanCount: _asInt(json['leftscancount']),
      status: CashCouponStatus.fromApiValue(_asInt(json['status'])),
      allowTransfer: _asBool(json['allowtransfer']),
      cashCouponConfigId: _asInt(json['cashcouponconfigid']),
      cashCouponId: _asInt(json['cashcouponid']),
      couponCount: _asInt(json['couponcount']),
      couponName: _asString(json['couponname']),
      couponSn: _asString(json['couponsn']),
      endTime: _asDateTime(json['endtime']),
      money: _asDecimal(json['money']),
      productId: _asInt(json['productid']),
      productName: _asString(json['productname']),
      rebate: _asDecimal(json['rebate']),
      remark: _asString(json['remark']),
      shareGroup: _asString(json['sharegroup']),
      startTime: _asDateTime(json['starttime']),
      scanMarketCodeNth: _asInt(json['scanmarketcodenth']),
      scanedCount: _asInt(json['scanedcount']),
      requirement: _asString(json['requirement']),
    );
  }

  CouponGroupInfo toCardModel() {
    return CouponGroupInfo(
      couponName: couponName,
      couponTypeId: cashCouponConfigId,
      money: money,
      limitLowAmount: Decimal.zero,
      startTime: startTime,
      endTime: endTime,
      status: switch (status) {
        CashCouponStatus.valid => CouponGroupStatus.valid,
        CashCouponStatus.used => CouponGroupStatus.used,
        CashCouponStatus.expired => CouponGroupStatus.expired,
      },
      available: status == CashCouponStatus.valid,
      count: couponCount,
      canTransfer: allowTransfer,
    );
  }
}

class CashCouponListResult {
  final List<CashCouponInfo> coupons;
  final int totalCount;
  final bool hasMore;
  final String? dataTag;

  const CashCouponListResult({required this.coupons, required this.totalCount, required this.hasMore, this.dataTag});

  factory CashCouponListResult.fromJson(Map<String, dynamic> json) {
    final rawCoupons = json['coupons'];
    final coupons = rawCoupons is List
        ? rawCoupons.whereType<Map>().map((item) => CashCouponInfo.fromJson(Map<String, dynamic>.from(item))).toList(growable: false)
        : const <CashCouponInfo>[];

    return CashCouponListResult(
      coupons: coupons,
      totalCount: _asInt(json['totalcount']),
      hasMore: _asBool(json['hasmore']),
      dataTag: json['datatag']?.toString(),
    );
  }
}

class CashCouponDetailResult {
  final CashCouponInfo? detail;
  final String? dataTag;

  const CashCouponDetailResult({this.detail, this.dataTag});

  factory CashCouponDetailResult.fromJson(Map<String, dynamic> json) {
    final rawDetail = json['detail'];
    return CashCouponDetailResult(
      detail: rawDetail is Map ? CashCouponInfo.fromJson(Map<String, dynamic>.from(rawDetail)) : null,
      dataTag: json['datatag']?.toString(),
    );
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

DateTime? _asDateTime(dynamic value) {
  if (value is DateTime) return value;
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : DateTime.tryParse(text);
}
