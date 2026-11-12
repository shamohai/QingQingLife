import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qingqinglife/core/logging/app_logger.dart';

import '../../../../core/providers/repository_providers.dart';
import 'service_coupon_list_provider.dart';

typedef ServiceCouponReceiveArgs = ({String shareGroupId, int serviceCouponId});

class ServiceCouponReceiveState {
  final bool submitting;
  final bool received;
  final String? errorMessage;

  const ServiceCouponReceiveState({this.submitting = false, this.received = false, this.errorMessage});

  ServiceCouponReceiveState copyWith({bool? submitting, bool? received, String? errorMessage, bool clearError = false}) {
    return ServiceCouponReceiveState(
      submitting: submitting ?? this.submitting,
      received: received ?? this.received,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ServiceCouponReceiveNotifier extends Notifier<ServiceCouponReceiveState> {
  final ServiceCouponReceiveArgs args;

  ServiceCouponReceiveNotifier(this.args);

  @override
  ServiceCouponReceiveState build() => const ServiceCouponReceiveState();

  Future<bool> receive() async {
    if (state.submitting || state.received) return state.received;
    if (args.shareGroupId.trim().isEmpty) {
      state = state.copyWith(errorMessage: '分享链接无效，请重新获取好友分享');
      return false;
    }

    state = state.copyWith(submitting: true, clearError: true);
    try {
      final response = await ref.read(memberRepositoryProvider).receiveServiceCoupon(shareGroupId: args.shareGroupId, serviceCouponId: args.serviceCouponId);
      if (!response.success) {
        state = state.copyWith(submitting: false, errorMessage: _friendlyMessage(response.message));
        return false;
      }

      state = state.copyWith(submitting: false, received: true, clearError: true);
      await ref.read(serviceCouponListProvider.notifier).load();
      return true;
    } catch (error) {
      AppLogger.error('receive error', module: 'service_coupon_receive', error: error);
      state = state.copyWith(submitting: false, errorMessage: '领取失败，请稍后重试');
      return false;
    }
  }

  static String _friendlyMessage(String? raw) {
    final message = raw?.trim() ?? '';
    if (message.isEmpty || message == 'unknown error') return '领取失败，请稍后重试';
    return message;
  }
}

final serviceCouponReceiveProvider = NotifierProvider.autoDispose.family<ServiceCouponReceiveNotifier, ServiceCouponReceiveState, ServiceCouponReceiveArgs>(
  (args) => ServiceCouponReceiveNotifier(args),
);
