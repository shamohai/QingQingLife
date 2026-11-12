import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/service_coupon_model.dart';

class ServiceCouponListState {
  final ServiceCouponStatus status;
  final bool loading;
  final String? errorMessage;
  final List<ServiceCouponInfo> coupons;

  const ServiceCouponListState({this.status = ServiceCouponStatus.valid, this.loading = false, this.errorMessage, this.coupons = const []});

  ServiceCouponListState copyWith({
    ServiceCouponStatus? status,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    List<ServiceCouponInfo>? coupons,
  }) {
    return ServiceCouponListState(
      status: status ?? this.status,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      coupons: coupons ?? this.coupons,
    );
  }
}

final serviceCouponListProvider = NotifierProvider<ServiceCouponListNotifier, ServiceCouponListState>(() => ServiceCouponListNotifier());

class ServiceCouponListNotifier extends Notifier<ServiceCouponListState> {
  int _requestToken = 0;

  @override
  ServiceCouponListState build() => const ServiceCouponListState();

  Future<void> load() async {
    final status = state.status;
    final token = ++_requestToken;
    state = state.copyWith(loading: true, clearError: true);

    try {
      final response = await ref.read(memberRepositoryProvider).getServiceCouponList(status: status);
      if (token != _requestToken || state.status != status) return;

      if (!response.success || response.data == null) {
        state = state.copyWith(loading: false, errorMessage: _friendlyMessage(response.message));
        return;
      }

      state = state.copyWith(loading: false, coupons: response.data!.coupons, clearError: true);
    } finally {
      if (token == _requestToken && state.status == status) state = state.copyWith(loading: false);
    }
  }

  Future<void> selectStatus(ServiceCouponStatus status) async {
    if (status == state.status && !state.loading) return;

    _requestToken++;
    state = ServiceCouponListState(status: status, loading: true);
    await load();
  }

  static String _friendlyMessage(String? raw) {
    final message = raw?.trim() ?? '';
    if (message.isEmpty || message == 'unknown error') return '服务券加载失败，请稍后重试';
    return message;
  }
}
