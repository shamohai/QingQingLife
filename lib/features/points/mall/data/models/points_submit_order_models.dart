/// 提交青稞粒/自营积分订单请求 (`SubmitCreditOrderMsgReq`)
class SubmitCreditOrderReq {
  final int pid;
  final int num;
  final int addressId;
  final int userServiceId;
  final String? remark;

  const SubmitCreditOrderReq({required this.pid, required this.num, required this.addressId, this.userServiceId = 0, this.remark});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'products': <Map<String, dynamic>>[
        <String, dynamic>{'pid': pid, 'num': num},
      ],
      'addressid': addressId,
      'userserviceid': userServiceId,
      'remark': remark ?? '',
    };
  }
}

/// 提交青稞粒/自营积分订单响应 (`SubmitCreditOrderMsgResp`)
class SubmitCreditOrderResp {
  final int result;
  final String? descr;
  final List<int> orderIds;
  final num? surplusMoney;

  const SubmitCreditOrderResp({required this.result, this.descr, this.orderIds = const [], this.surplusMoney});

  factory SubmitCreditOrderResp.fromJson(Map<String, dynamic> json) {
    final rawResult = json['result'] ?? json['Result'] ?? -1;
    final parsedResult = rawResult is num ? rawResult.toInt() : int.tryParse('$rawResult') ?? -1;

    final rawDescr = (json['descr'] ?? json['Descr']) as String?;

    List<int> parsedOrderIds = [];
    final rawOrderIds = json['orderids'] ?? json['OrderIds'] ?? json['orderid'] ?? json['OrderId'];
    if (rawOrderIds is List) {
      parsedOrderIds = rawOrderIds.map((e) => e is num ? e.toInt() : int.tryParse('$e') ?? 0).where((e) => e > 0).toList();
    } else if (rawOrderIds != null) {
      final singleId = rawOrderIds is num ? rawOrderIds.toInt() : int.tryParse('$rawOrderIds') ?? 0;
      if (singleId > 0) parsedOrderIds.add(singleId);
    }

    final rawSurplus = json['surplusmoney'] ?? json['SurplusMoney'];
    final parsedSurplus = rawSurplus is num ? rawSurplus : num.tryParse('$rawSurplus');

    return SubmitCreditOrderResp(result: parsedResult, descr: rawDescr, orderIds: parsedOrderIds, surplusMoney: parsedSurplus);
  }
}

/// 提交服务券兑换订单请求 (`SubmitServiceCouponIntegralOrderMsgReq`)
class SubmitServiceCouponIntegralOrderReq {
  final int pid;
  final int num;

  const SubmitServiceCouponIntegralOrderReq({required this.pid, required this.num});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'pid': pid, 'num': num};
  }
}

/// 提交服务券兑换订单响应 (`SubmitServiceCouponIntegralOrderMsgResp`)
class SubmitServiceCouponIntegralOrderResp {
  final int result;
  final String? descr;
  final int? orderId;

  const SubmitServiceCouponIntegralOrderResp({required this.result, this.descr, this.orderId});

  factory SubmitServiceCouponIntegralOrderResp.fromJson(Map<String, dynamic> json) {
    final rawResult = json['result'] ?? json['Result'] ?? -1;
    final parsedResult = rawResult is num ? rawResult.toInt() : int.tryParse('$rawResult') ?? -1;

    final rawDescr = (json['descr'] ?? json['Descr']) as String?;

    final rawOrderId = json['orderid'] ?? json['OrderId'];
    final parsedOrderId = rawOrderId is num ? rawOrderId.toInt() : int.tryParse('$rawOrderId');

    return SubmitServiceCouponIntegralOrderResp(result: parsedResult, descr: rawDescr, orderId: parsedOrderId);
  }
}

/// 提交百礼汇第三方积分订单请求 (`SubmitBaiLiHuiOrderMsgReq`)
class SubmitBaiLiHuiOrderReq {
  final int pid;
  final int num;
  final int userServiceId;
  final String? mobile;
  final String? province;
  final String? city;
  final String? district;
  final String? address;
  final String? receiveName;

  const SubmitBaiLiHuiOrderReq({
    required this.pid,
    required this.num,
    this.userServiceId = 0,
    this.mobile,
    this.province,
    this.city,
    this.district,
    this.address,
    this.receiveName,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pid': pid,
      'num': num,
      'userserviceid': userServiceId,
      if (mobile != null && mobile!.isNotEmpty) 'mobile': mobile,
      if (province != null && province!.isNotEmpty) 'province': province,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (district != null && district!.isNotEmpty) 'district': district,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (receiveName != null && receiveName!.isNotEmpty) 'receiveName': receiveName,
    };
  }
}

/// 提交百礼汇第三方积分订单响应 (`SubmitBaiLiHuiOrderMsgResp`)
class SubmitBaiLiHuiOrderResp {
  final int result;
  final String? descr;
  final int? orderId;

  const SubmitBaiLiHuiOrderResp({required this.result, this.descr, this.orderId});

  factory SubmitBaiLiHuiOrderResp.fromJson(Map<String, dynamic> json) {
    final rawResult = json['result'] ?? json['Result'] ?? -1;
    final parsedResult = rawResult is num ? rawResult.toInt() : int.tryParse('$rawResult') ?? -1;

    final rawDescr = json['descr'] ?? json['Descr'];
    final parsedDescr = rawDescr?.toString();

    final rawOrderId = json['orderid'] ?? json['OrderId'];
    final parsedOrderId = rawOrderId is num ? rawOrderId.toInt() : int.tryParse('$rawOrderId');

    return SubmitBaiLiHuiOrderResp(result: parsedResult, descr: parsedDescr, orderId: parsedOrderId);
  }
}

/// 统一积分下单结果实体
class PointsOrderSubmitResult {
  final String orderId;
  final String orderNo;
  final int pointsDeducted;
  final String? message;

  const PointsOrderSubmitResult({required this.orderId, required this.orderNo, required this.pointsDeducted, this.message});
}
