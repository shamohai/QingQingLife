import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/service_coupon_model.dart';
import 'service_coupon_list_provider.dart';

class ServiceCouponTransferResult {
  final bool success;
  final String message;

  const ServiceCouponTransferResult({required this.success, required this.message});
}

class ServiceCouponTransferController {
  final Ref ref;

  ServiceCouponTransferController(this.ref);

  Future<ServiceCouponTransferResult> transfer({required ServiceCouponInfo coupon, required int count}) async {
    if (coupon.serviceCouponId <= 0) {
      return const ServiceCouponTransferResult(success: false, message: '服务券信息无效，请刷新后重试');
    }
    if (count <= 0 || count > coupon.num) {
      return ServiceCouponTransferResult(success: false, message: '最多可转账${coupon.num}张');
    }

    final response = await ref.read(memberRepositoryProvider).giveServiceCoupon(serviceCouponId: coupon.serviceCouponId, count: count);
    if (!response.success) {
      final message = response.message.trim();
      return ServiceCouponTransferResult(success: false, message: message.isEmpty || message == 'unknown error' ? '转赠失败，请稍后重试' : message);
    }

    await ref.read(serviceCouponListProvider.notifier).load();
    return const ServiceCouponTransferResult(success: true, message: '转赠成功');
  }
}

final serviceCouponTransferProvider = Provider<ServiceCouponTransferController>((ref) => ServiceCouponTransferController(ref));
