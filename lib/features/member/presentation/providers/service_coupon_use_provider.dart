import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/service_coupon_model.dart';

class ServiceCouponUseState {
  final ServiceCouponInfo? coupon;
  final int count;
  final bool loading;
  final String? errorMessage;
  final bool used;

  const ServiceCouponUseState({this.coupon, this.count = 1, this.loading = false, this.errorMessage, this.used = false});

  ServiceCouponUseState copyWith({ServiceCouponInfo? coupon, int? count, bool? loading, String? errorMessage, bool clearError = false, bool? used}) {
    return ServiceCouponUseState(
      coupon: coupon ?? this.coupon,
      count: count ?? this.count,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      used: used ?? this.used,
    );
  }
}

final serviceCouponUseProvider = NotifierProvider.autoDispose<ServiceCouponUseNotifier, ServiceCouponUseState>(ServiceCouponUseNotifier.new);

class ServiceCouponUseNotifier extends Notifier<ServiceCouponUseState> {
  Timer? _timer;
  int _couponTypeId = 0;
  String? _preferCouponSn;
  bool _requesting = false;

  @override
  ServiceCouponUseState build() {
    ref.onDispose(() => _timer?.cancel());
    return const ServiceCouponUseState();
  }

  void initialize(ServiceCouponInfo coupon) {
    _couponTypeId = coupon.couponTypeId;
    _preferCouponSn = coupon.couponSn.isEmpty ? null : coupon.couponSn;
    state = ServiceCouponUseState(coupon: coupon, count: 1, loading: true);
    _startPolling();
    unawaited(refresh());
  }

  /// 更新使用数量；超过明细 [ServiceCouponInfo.num] 时返回被限制后的最大值。
  int? setCount(int count) {
    final maxCount = _maxCount;
    if (count > maxCount) {
      if (state.count != maxCount) {
        state = state.copyWith(count: maxCount);
        unawaited(refresh());
      }
      return maxCount;
    }

    final nextCount = count.clamp(1, maxCount);
    if (nextCount == state.count) return null;
    state = state.copyWith(count: nextCount);
    unawaited(refresh());
    return null;
  }

  Future<void> refresh() async {
    if (_requesting || _couponTypeId <= 0 || state.used) return;
    _requesting = true;

    try {
      final response = await ref
          .read(memberRepositoryProvider)
          .refreshServiceCouponInfoV2(couponTypeId: _couponTypeId, count: state.count, preferCouponSn: _preferCouponSn);
      if (response.success && response.data?.coupon != null) {
        final coupon = response.data!.coupon!;
        final used = coupon.isUsed;
        if (used) _timer?.cancel();
        final nextCount = coupon.num > 0 ? state.count.clamp(1, coupon.num) : state.count;
        state = state.copyWith(coupon: coupon, count: nextCount, loading: false, clearError: true, used: used);
      } else {
        state = state.copyWith(loading: false, errorMessage: _friendlyMessage(response.message));
      }
    } catch (error) {
      debugPrint('[ServiceCouponUse] refresh error: $error');
      state = state.copyWith(loading: false, errorMessage: '服务券信息刷新失败，请稍后重试');
    } finally {
      _requesting = false;
    }
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => unawaited(refresh()));
  }

  int get _maxCount {
    final num = state.coupon?.num ?? 0;
    return num > 0 ? num : 1;
  }

  static String _friendlyMessage(String? raw) {
    final message = raw?.trim() ?? '';
    if (message.isEmpty || message == 'unknown error') return '服务券信息刷新失败，请稍后重试';
    return message;
  }
}
