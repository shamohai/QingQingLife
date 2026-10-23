import 'package:decimal/decimal.dart';

/// 服务券状态。
///
/// 对齐接口文档 POST /api/promotion/getservicecouponlist：
///   0 未使用 / 1 已失效 / 2 转赠中。
enum ServiceCouponStatus {
  valid(0, '未使用'),
  invalid(1, '已失效'),
  transferring(2, '转赠中');

  const ServiceCouponStatus(this.apiValue, this.label);

  final int apiValue;
  final String label;

  static ServiceCouponStatus fromApiValue(dynamic value) {
    final apiValue = _asInt(value);
    return ServiceCouponStatus.values.firstWhere((status) => status.apiValue == apiValue, orElse: () => ServiceCouponStatus.valid);
  }
}

/// 服务券列表项。
class ServiceCouponInfo {
  final String barcodeUrl;
  final String batchId;
  final int giveState;
  final bool canDeliver;
  final bool canTransfer;
  final String couponName;
  final String couponSn;
  final int couponType;
  final int couponTypeId;
  final DateTime? endTime;
  final String? image;
  final Decimal money;
  final int num;
  final String qrCodeContent;
  final String qrUrl;
  final String remark;
  final int serviceCouponId;
  final String shareGroup;
  final ServiceCouponStatus status;
  final String statusText;
  final bool userSettlement;

  const ServiceCouponInfo({
    this.barcodeUrl = '',
    this.batchId = '',
    this.giveState = 0,
    this.canDeliver = false,
    this.canTransfer = false,
    required this.couponName,
    this.couponSn = '',
    this.couponType = 0,
    this.couponTypeId = 0,
    this.endTime,
    this.image,
    required this.money,
    this.num = 0,
    this.qrCodeContent = '',
    this.qrUrl = '',
    this.remark = '',
    this.serviceCouponId = 0,
    this.shareGroup = '',
    this.status = ServiceCouponStatus.valid,
    this.statusText = '',
    this.userSettlement = false,
  });

  factory ServiceCouponInfo.fromJson(Map<String, dynamic> json) {
    final statusText = _asString(json['status']);
    return ServiceCouponInfo(
      barcodeUrl: _asString(json['barcodeurl']),
      batchId: _asString(json['batchid']),
      giveState: _asInt(json['givestate']),
      canDeliver: _asBool(json['candeliver']),
      canTransfer: _asBool(json['cantransfer']),
      couponName: _asString(json['couponname']),
      couponSn: _asString(json['couponsn']),
      couponType: _asInt(json['coupontype']),
      couponTypeId: _asInt(json['coupontypeid']),
      endTime: _asDateTime(json['endtime']),
      image: json['image']?.toString(),
      money: _asDecimal(json['money']),
      num: _asInt(json['num']),
      qrCodeContent: _asString(json['qrcodecontent']),
      qrUrl: _asString(json['qrurl']),
      remark: _asString(json['remark']),
      serviceCouponId: _asInt(json['servicecouponid']),
      shareGroup: _asString(json['sharegroup']),
      status: ServiceCouponStatus.fromApiValue(statusText),
      statusText: statusText,
      userSettlement: _asBool(json['usersettlement']),
    );
  }

  /// 核销使用完成后，刷新接口会把状态文本变成“已核销”等结果。
  bool get isUsed {
    final normalized = statusText.trim().toLowerCase();
    return normalized.contains('核销') || normalized.contains('已使用') || normalized.contains('used');
  }
}

class ServiceCouponInfoResult {
  final ServiceCouponInfo? coupon;
  final String? dataTag;

  const ServiceCouponInfoResult({this.coupon, this.dataTag});

  factory ServiceCouponInfoResult.fromJson(Map<String, dynamic> json) {
    final rawCoupon = json['coupon'];
    return ServiceCouponInfoResult(
      coupon: rawCoupon is Map ? ServiceCouponInfo.fromJson(Map<String, dynamic>.from(rawCoupon)) : null,
      dataTag: json['datatag']?.toString(),
    );
  }
}

class ServiceCouponListResult {
  final List<ServiceCouponInfo> coupons;
  final String? dataTag;

  const ServiceCouponListResult({required this.coupons, this.dataTag});

  factory ServiceCouponListResult.fromJson(Map<String, dynamic> json) {
    final rawCoupons = json['coupons'];
    final coupons = rawCoupons is List
        ? rawCoupons.whereType<Map>().map((item) => ServiceCouponInfo.fromJson(Map<String, dynamic>.from(item))).toList(growable: false)
        : const <ServiceCouponInfo>[];
    return ServiceCouponListResult(coupons: coupons, dataTag: json['datatag']?.toString());
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
