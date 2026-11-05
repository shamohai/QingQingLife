import 'package:decimal/decimal.dart';

/// 发起会员待解锁红包分享的接口结果。
class BeginCashCouponShareResult {
  final String shareCode;
  final String shareTitle;
  final String shareIcon;
  final DateTime? shareExpireTime;
  final String? dataTag;

  const BeginCashCouponShareResult({required this.shareCode, this.shareTitle = '', this.shareIcon = '', this.shareExpireTime, this.dataTag});

  factory BeginCashCouponShareResult.fromJson(Map<String, dynamic> json) {
    return BeginCashCouponShareResult(
      shareCode: _asString(json['sharecode']),
      shareTitle: _asString(json['sharetitle']),
      shareIcon: _asString(json['shareicon']),
      shareExpireTime: _asDateTime(json['shareexpiretime']),
      dataTag: json['datatag']?.toString(),
    );
  }
}

/// 通过分享链接预览或领取待解锁红包的接口结果。
class ReceiveCashCouponFromShareResult {
  final CashCouponShareConfigInfo? configInfo;
  final bool canReceive;
  final String reason;
  final String fromUserName;
  final String activityDescriptionHtml;
  final DateTime? shareExpireTime;
  final String? dataTag;

  const ReceiveCashCouponFromShareResult({
    this.configInfo,
    this.canReceive = false,
    this.reason = '',
    this.fromUserName = '',
    this.activityDescriptionHtml = '',
    this.shareExpireTime,
    this.dataTag,
  });

  factory ReceiveCashCouponFromShareResult.fromJson(Map<String, dynamic> json) {
    final rawConfigInfo = json['configinfo'];
    return ReceiveCashCouponFromShareResult(
      configInfo: rawConfigInfo is Map ? CashCouponShareConfigInfo.fromJson(Map<String, dynamic>.from(rawConfigInfo)) : null,
      canReceive: _asBool(json['canrecv']),
      reason: _asString(json['reason']),
      fromUserName: _asString(json['fromusername']),
      activityDescriptionHtml: _asString(json['activitydescrhtml']),
      shareExpireTime: _asDateTime(json['shareexpiretime']),
      dataTag: json['datatag']?.toString(),
    );
  }
}

/// 分享红包的配置详情，由领取接口返回。
class CashCouponShareConfigInfo {
  final int cashCouponConfigId;
  final Decimal rebate;
  final String couponName;
  final int productId;
  final String productName;
  final Decimal money;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool allowTransfer;
  final String remark;

  const CashCouponShareConfigInfo({
    this.cashCouponConfigId = 0,
    required this.rebate,
    this.couponName = '',
    this.productId = 0,
    this.productName = '',
    required this.money,
    this.startTime,
    this.endTime,
    this.allowTransfer = false,
    this.remark = '',
  });

  factory CashCouponShareConfigInfo.fromJson(Map<String, dynamic> json) {
    return CashCouponShareConfigInfo(
      cashCouponConfigId: _asInt(json['cashcouponconfigid']),
      rebate: _asDecimal(json['rebate']),
      couponName: _asString(json['couponname']),
      productId: _asInt(json['productid']),
      productName: _asString(json['productname']),
      money: _asDecimal(json['money']),
      startTime: _asDateTime(json['starttime']),
      endTime: _asDateTime(json['endtime']),
      allowTransfer: _asBool(json['allowtransfer']),
      remark: _asString(json['remark']),
    );
  }
}

String _asString(dynamic value) => value?.toString() ?? '';

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().toLowerCase();
  return normalized == 'true' || normalized == '1';
}

Decimal _asDecimal(dynamic value) {
  if (value is Decimal) return value;
  return Decimal.tryParse(value?.toString() ?? '') ?? Decimal.zero;
}

DateTime? _asDateTime(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : DateTime.tryParse(text);
}
