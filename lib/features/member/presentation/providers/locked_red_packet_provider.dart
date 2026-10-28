import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/cash_coupon_model.dart';

class LockedRedPacketListState {
  final CashCouponStatus status;
  final bool loading;
  final bool loadingMore;
  final String? errorMessage;
  final List<CashCouponInfo> coupons;
  final int totalCount;
  final bool hasMore;
  final int pageIndex;

  const LockedRedPacketListState({
    this.status = CashCouponStatus.valid,
    this.loading = false,
    this.loadingMore = false,
    this.errorMessage,
    this.coupons = const [],
    this.totalCount = 0,
    this.hasMore = false,
    this.pageIndex = 0,
  });

  LockedRedPacketListState copyWith({
    CashCouponStatus? status,
    bool? loading,
    bool? loadingMore,
    String? errorMessage,
    bool clearError = false,
    List<CashCouponInfo>? coupons,
    int? totalCount,
    bool? hasMore,
    int? pageIndex,
  }) {
    return LockedRedPacketListState(
      status: status ?? this.status,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      coupons: coupons ?? this.coupons,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }
}

final lockedRedPacketListProvider = NotifierProvider<LockedRedPacketListNotifier, LockedRedPacketListState>(LockedRedPacketListNotifier.new);

class LockedRedPacketListNotifier extends Notifier<LockedRedPacketListState> {
  static const int pageSize = 20;

  int _requestToken = 0;

  @override
  LockedRedPacketListState build() => const LockedRedPacketListState();

  Future<void> load() async {
    final status = state.status;
    final token = ++_requestToken;
    state = state.copyWith(loading: true, loadingMore: false, clearError: true);

    try {
      final response = await ref.read(memberRepositoryProvider).getCashCouponList(status: status, pageIndex: 1, pageSize: pageSize);
      if (token != _requestToken || state.status != status) return;

      if (!response.success || response.data == null) {
        state = state.copyWith(loading: false, errorMessage: _friendlyMessage(response.message));
        return;
      }

      final result = response.data!;
      state = state.copyWith(loading: false, coupons: result.coupons, totalCount: result.totalCount, hasMore: result.hasMore, pageIndex: 1, clearError: true);
    } catch (error) {
      if (token != _requestToken || state.status != status) return;
      debugPrint('[LockedRedPacketList] load error: $error');
      state = state.copyWith(loading: false, errorMessage: '红包加载失败，请稍后重试');
    }
  }

  Future<void> selectStatus(CashCouponStatus status) async {
    if (status == state.status && !state.loading) return;

    _requestToken++;
    state = LockedRedPacketListState(status: status, loading: true);
    await load();
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;

    final status = state.status;
    final nextPage = state.pageIndex + 1;
    final token = ++_requestToken;
    state = state.copyWith(loadingMore: true, clearError: true);

    try {
      final response = await ref.read(memberRepositoryProvider).getCashCouponList(status: status, pageIndex: nextPage, pageSize: pageSize);
      if (token != _requestToken || state.status != status) return;

      if (!response.success || response.data == null) {
        state = state.copyWith(loadingMore: false, errorMessage: _friendlyMessage(response.message));
        return;
      }

      final result = response.data!;
      state = state.copyWith(
        loadingMore: false,
        coupons: [...state.coupons, ...result.coupons],
        totalCount: result.totalCount,
        hasMore: result.hasMore,
        pageIndex: nextPage,
        clearError: true,
      );
    } catch (error) {
      if (token != _requestToken || state.status != status) return;
      debugPrint('[LockedRedPacketList] load more error: $error');
      state = state.copyWith(loadingMore: false, errorMessage: '加载更多失败，请稍后重试');
    }
  }

  static String _friendlyMessage(String? raw) {
    final message = raw?.trim() ?? '';
    if (message.isEmpty || message == 'unknown error') return '红包加载失败，请稍后重试';
    return message;
  }
}

final cashCouponDetailProvider = FutureProvider.autoDispose.family<CashCouponInfo, String>((ref, couponSn) async {
  final response = await ref.read(memberRepositoryProvider).getCashCouponDetail(couponSn: couponSn);
  final detail = response.data?.detail;
  if (!response.success || detail == null) {
    throw Exception(response.message.isEmpty ? '红包详情加载失败，请稍后重试' : response.message);
  }
  return detail;
});
