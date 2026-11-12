import 'package:qingqinglife/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/models/cash_coupon_share_model.dart';

class CashCouponShareStartResult {
  final bool success;
  final bool busy;
  final String message;
  final BeginCashCouponShareResult? share;

  const CashCouponShareStartResult({required this.success, this.busy = false, this.message = '', this.share});
}

class CashCouponShareController {
  CashCouponShareController(this.ref);

  final Ref ref;
  final Set<int> _startingUserServiceIds = {};

  Future<CashCouponShareStartResult> begin({required int userServiceId, required int cashCouponConfigId}) async {
    if (userServiceId <= 0 || cashCouponConfigId <= 0) {
      return const CashCouponShareStartResult(success: false, message: '红包权益信息无效，请刷新后重试');
    }
    if (!_startingUserServiceIds.add(userServiceId)) {
      return const CashCouponShareStartResult(success: false, busy: true);
    }

    try {
      final response = await ref.read(memberRepositoryProvider).beginCashCouponShare(userServiceId: userServiceId, cashCouponConfigId: cashCouponConfigId);
      if (!response.success || response.data == null) {
        return CashCouponShareStartResult(success: false, message: _friendlyMessage(response.message, '发起分享失败，请稍后重试'));
      }
      if (response.data!.shareCode.trim().isEmpty) {
        return const CashCouponShareStartResult(success: false, message: '分享已发起，但未获取到分享编号，请稍后重试');
      }
      return CashCouponShareStartResult(success: true, share: response.data);
    } catch (error) {
      AppLogger.error('begin error', module: 'cash_coupon_share', error: error);
      return const CashCouponShareStartResult(success: false, message: '发起分享失败，请稍后重试');
    } finally {
      _startingUserServiceIds.remove(userServiceId);
    }
  }

  static String _friendlyMessage(String? raw, String fallback) => friendlyMessageOr(raw, fallback);
}

final cashCouponShareControllerProvider = Provider<CashCouponShareController>((ref) => CashCouponShareController(ref));

class CashCouponShareReceiveState {
  final bool loading;
  final bool loaded;
  final bool submitting;
  final bool received;
  final String? errorMessage;
  final ReceiveCashCouponFromShareResult? result;

  const CashCouponShareReceiveState({
    this.loading = false,
    this.loaded = false,
    this.submitting = false,
    this.received = false,
    this.errorMessage,
    this.result,
  });

  CashCouponShareReceiveState copyWith({
    bool? loading,
    bool? loaded,
    bool? submitting,
    bool? received,
    String? errorMessage,
    bool clearError = false,
    ReceiveCashCouponFromShareResult? result,
    bool clearResult = false,
  }) {
    return CashCouponShareReceiveState(
      loading: loading ?? this.loading,
      loaded: loaded ?? this.loaded,
      submitting: submitting ?? this.submitting,
      received: received ?? this.received,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

final cashCouponShareReceiveProvider = NotifierProvider.autoDispose.family<CashCouponShareReceiveNotifier, CashCouponShareReceiveState, String>(
  (shareCode) => CashCouponShareReceiveNotifier(shareCode),
);

class CashCouponShareReceiveNotifier extends Notifier<CashCouponShareReceiveState> {
  CashCouponShareReceiveNotifier(this.shareCode);

  final String shareCode;

  @override
  CashCouponShareReceiveState build() => const CashCouponShareReceiveState();

  Future<void> load() async {
    if (state.loading) return;
    final normalizedShareCode = shareCode.trim();
    if (normalizedShareCode.isEmpty) {
      state = state.copyWith(loaded: true, errorMessage: '分享链接无效，请让好友重新分享');
      return;
    }

    state = state.copyWith(loading: true, loaded: false, clearError: true, clearResult: true);
    try {
      final response = await ref.read(memberRepositoryProvider).receiveCashCouponFromShare(shareCode: normalizedShareCode, doReceive: false);
      if (!response.success || response.data == null) {
        state = state.copyWith(loading: false, loaded: true, errorMessage: _friendlyMessage(response.message, '红包信息加载失败，请稍后重试'));
        return;
      }
      state = state.copyWith(loading: false, loaded: true, result: response.data, clearError: true);
    } catch (error) {
      AppLogger.error('preview error', module: 'cash_coupon_share_receive', error: error);
      state = state.copyWith(loading: false, loaded: true, errorMessage: '红包信息加载失败，请稍后重试');
    }
  }

  Future<bool> receive() async {
    if (state.submitting || state.received) return state.received;
    if (!state.loaded || state.loading) return false;

    final currentResult = state.result;
    if (currentResult == null || !currentResult.canReceive) {
      state = state.copyWith(errorMessage: currentResult?.reason.isNotEmpty == true ? currentResult!.reason : '当前红包暂不可领取');
      return false;
    }

    state = state.copyWith(submitting: true, clearError: true);
    try {
      final response = await ref.read(memberRepositoryProvider).receiveCashCouponFromShare(shareCode: shareCode.trim(), doReceive: true);
      if (!response.success || response.data == null) {
        state = state.copyWith(submitting: false, errorMessage: _friendlyMessage(response.message, '领取失败，请稍后重试'));
        return false;
      }
      if (!response.data!.canReceive) {
        final reason = response.data!.reason.trim();
        state = state.copyWith(submitting: false, result: response.data, errorMessage: reason.isEmpty ? '当前红包暂不可领取' : reason);
        return false;
      }

      state = state.copyWith(submitting: false, received: true, result: response.data, clearError: true);
      return true;
    } catch (error) {
      AppLogger.error('receive error', module: 'cash_coupon_share_receive', error: error);
      state = state.copyWith(submitting: false, errorMessage: '领取失败，请稍后重试');
      return false;
    }
  }

  static String _friendlyMessage(String? raw, String fallback) => friendlyMessageOr(raw, fallback);
}
