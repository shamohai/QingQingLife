import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/service_coupon_model.dart';
import 'service_coupon_list_provider.dart';

class ServiceCouponTransferResult {
  final bool success;
  final String message;
  final String shareGroup;

  const ServiceCouponTransferResult({required this.success, required this.message, this.shareGroup = ''});
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

    final shareGroup = response.data?.shareGroup.trim() ?? '';
    await ref.read(serviceCouponListProvider.notifier).load();
    return ServiceCouponTransferResult(success: true, message: '转赠成功', shareGroup: shareGroup);
  }

  Future<ServiceCouponTransferResult> revoke({required ServiceCouponInfo coupon}) async {
    final shareGroup = coupon.shareGroup.trim();
    if (coupon.serviceCouponId <= 0 && shareGroup.isEmpty) {
      return const ServiceCouponTransferResult(success: false, message: '服务券信息无效，请刷新后重试');
    }

    try {
      final response = await ref.read(memberRepositoryProvider).revokeServiceCoupon(serviceCouponId: coupon.serviceCouponId, shareGroup: shareGroup);
      if (!response.success) {
        final message = response.message.trim();
        return ServiceCouponTransferResult(success: false, message: message.isEmpty || message == 'unknown error' ? '取消转赠失败，请稍后重试' : message);
      }

      await ref.read(serviceCouponListProvider.notifier).load();
      return const ServiceCouponTransferResult(success: true, message: '取消转赠成功');
    } catch (_) {
      return const ServiceCouponTransferResult(success: false, message: '取消转赠失败，请稍后重试');
    }
  }
}

final serviceCouponTransferProvider = Provider<ServiceCouponTransferController>((ref) => ServiceCouponTransferController(ref));
