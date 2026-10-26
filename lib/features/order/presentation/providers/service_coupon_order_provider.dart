import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/service_coupon_order.dart';

typedef ServiceCouponPreDealQuery = ({int serviceCouponId, int count, int? addressId});

/// 服务券订单预处理。
///
/// 每次服务券张数或收货地址变化时重新请求，金额与可用券信息始终以服务端为准。
final serviceCouponPreDealProvider = FutureProvider.family.autoDispose<ServiceCouponPreDealData, ServiceCouponPreDealQuery>((ref, query) async {
  final response = await ref
      .read(orderRepositoryProvider)
      .preDealServiceCouponOrder(serviceCouponId: query.serviceCouponId, count: query.count, addressId: query.addressId);
  if (!response.success || response.data == null) {
    throw Exception(response.message);
  }
  return response.data!;
});

class ServiceCouponOrderController {
  const ServiceCouponOrderController(this._ref);

  final Ref _ref;

  Future<ApiResponse<ServiceCouponOrderSubmitResult>> submit({
    required int serviceCouponId,
    required int count,
    required int addressId,
    String? remark,
    DateTime? sendTime,
  }) {
    return _ref
        .read(orderRepositoryProvider)
        .submitServiceCouponOrder(serviceCouponId: serviceCouponId, count: count, addressId: addressId, remark: remark, sendTime: sendTime);
  }
}

final serviceCouponOrderControllerProvider = Provider<ServiceCouponOrderController>((ref) {
  return ServiceCouponOrderController(ref);
});
