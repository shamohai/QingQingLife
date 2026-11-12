import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qingqinglife/core/logging/app_logger.dart';

import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/models/coupon_group_model.dart';

class CouponListState {
  final CouponGroupStatus status;
  final bool loading;
  final String? errorMessage;
  final List<CouponGroupInfo> coupons;
  final int totalCount;

  const CouponListState({this.status = CouponGroupStatus.valid, this.loading = false, this.errorMessage, this.coupons = const [], this.totalCount = 0});

  bool get isEmpty => !loading && errorMessage == null && coupons.isEmpty;

  CouponListState copyWith({
    CouponGroupStatus? status,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    List<CouponGroupInfo>? coupons,
    int? totalCount,
  }) {
    return CouponListState(
      status: status ?? this.status,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      coupons: coupons ?? this.coupons,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

final couponListProvider = NotifierProvider<CouponListNotifier, CouponListState>(() => CouponListNotifier());

class CouponListNotifier extends Notifier<CouponListState> {
  int _requestToken = 0;

  @override
  CouponListState build() => const CouponListState();

  Future<void> load() async {
    final status = state.status;
    final token = ++_requestToken;
    state = state.copyWith(loading: true, clearError: true);

    try {
      final response = await ref.read(memberRepositoryProvider).getCouponGroupList(status: status);
      if (token != _requestToken || state.status != status) return;

      if (!response.success || response.data == null) {
        state = state.copyWith(loading: false, errorMessage: friendlyMessageOr(response.message, '优惠券加载失败，请稍后重试'));
        return;
      }

      final result = response.data!;
      state = state.copyWith(loading: false, coupons: result.coupons, totalCount: result.totalCount, clearError: true);
    } catch (error) {
      if (token != _requestToken || state.status != status) return;
      AppLogger.error('load error', module: 'coupon_list', error: error);
      state = state.copyWith(loading: false, errorMessage: '优惠券加载失败，请稍后重试');
    }
  }

  Future<void> selectStatus(CouponGroupStatus status) async {
    if (status == state.status && !state.loading) return;

    _requestToken++;
    state = CouponListState(status: status, loading: true);
    await load();
  }
}
