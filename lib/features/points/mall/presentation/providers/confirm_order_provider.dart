import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/logging/app_logger.dart';
import '../../../../../core/network/api_response.dart';
import '../../../../../core/providers/repository_providers.dart';
import '../../../../member/domain/repositories/member_repository.dart';
import '../../data/models/points_submit_order_models.dart';
import '../../data/models/pre_credit_order_info_model.dart';

/// 确认订单页面参数
class PointsConfirmOrderArg {
  final String productId;
  final int userServiceId;

  const PointsConfirmOrderArg({required this.productId, this.userServiceId = 0});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointsConfirmOrderArg && runtimeType == other.runtimeType && productId == other.productId && userServiceId == other.userServiceId;

  @override
  int get hashCode => Object.hash(productId, userServiceId);
}

/// 确认订单页面本地与网络集成状态
class PointsConfirmOrderState {
  final String productId;
  final int userServiceId;
  final int quantity;
  final bool isQuantityEditable;
  final AsyncValue<PreCreditOrderInfoModel> preOrderInfoAsync;
  final AsyncValue<MemberAddress?> addressAsync;
  final String redeemerPhone;
  final bool isSubmitting;
  final bool isPreOrderValidating;
  final String? quantityValidationError;

  const PointsConfirmOrderState({
    required this.productId,
    this.userServiceId = 0,
    this.quantity = 1,
    this.isQuantityEditable = true,
    this.preOrderInfoAsync = const AsyncValue.loading(),
    this.addressAsync = const AsyncValue.data(null),
    this.redeemerPhone = '',
    this.isSubmitting = false,
    this.isPreOrderValidating = false,
    this.quantityValidationError,
  });

  PointsConfirmOrderState copyWith({
    String? productId,
    int? userServiceId,
    int? quantity,
    bool? isQuantityEditable,
    AsyncValue<PreCreditOrderInfoModel>? preOrderInfoAsync,
    AsyncValue<MemberAddress?>? addressAsync,
    String? redeemerPhone,
    bool? isSubmitting,
    bool? isPreOrderValidating,
    String? quantityValidationError,
    bool clearQuantityValidationError = false,
  }) {
    return PointsConfirmOrderState(
      productId: productId ?? this.productId,
      userServiceId: userServiceId ?? this.userServiceId,
      quantity: quantity ?? this.quantity,
      isQuantityEditable: isQuantityEditable ?? this.isQuantityEditable,
      preOrderInfoAsync: preOrderInfoAsync ?? this.preOrderInfoAsync,
      addressAsync: addressAsync ?? this.addressAsync,
      redeemerPhone: redeemerPhone ?? this.redeemerPhone,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isPreOrderValidating: isPreOrderValidating ?? this.isPreOrderValidating,
      quantityValidationError: clearQuantityValidationError ? null : quantityValidationError ?? this.quantityValidationError,
    );
  }
}

class PointsConfirmOrderNotifier extends Notifier<PointsConfirmOrderState> {
  final PointsConfirmOrderArg arg;

  PointsConfirmOrderNotifier(this.arg);

  @override
  PointsConfirmOrderState build() {
    final isEditable = arg.userServiceId <= 0;
    Future.microtask(() => _fetchPreOrderInfo(quantity: 1, initial: true));
    return PointsConfirmOrderState(
      productId: arg.productId,
      userServiceId: arg.userServiceId,
      quantity: 1,
      isQuantityEditable: isEditable,
      preOrderInfoAsync: const AsyncValue.loading(),
      addressAsync: const AsyncValue.data(null),
    );
  }

  int _preOrderRequestId = 0;

  Future<void> _fetchPreOrderInfo({required int quantity, bool initial = false}) async {
    if (!ref.mounted) return;
    final requestId = ++_preOrderRequestId;
    final hasCurrentPreOrder = state.preOrderInfoAsync.hasValue;
    state = state.copyWith(
      preOrderInfoAsync: initial && !hasCurrentPreOrder ? const AsyncValue.loading() : state.preOrderInfoAsync,
      isPreOrderValidating: true,
      clearQuantityValidationError: true,
    );

    try {
      final repository = ref.read(pointsRepositoryProvider);
      final response = await repository.getPreCreditOrderInfo(userServiceId: state.userServiceId, productId: state.productId, quantity: quantity);
      if (!ref.mounted || requestId != _preOrderRequestId) return;

      if (response.success && response.data != null) {
        final preInfo = response.data!;
        if (preInfo.recvrType == RecvrType.shipAddress && (initial || state.addressAsync.value == null)) {
          await refreshAddress();
          if (!ref.mounted || requestId != _preOrderRequestId) return;
        }
        state = state.copyWith(
          quantity: quantity,
          preOrderInfoAsync: AsyncValue.data(preInfo),
          isPreOrderValidating: false,
          clearQuantityValidationError: true,
          addressAsync: preInfo.recvrType == RecvrType.shipAddress ? state.addressAsync : const AsyncValue.data(null),
        );
      } else {
        _handlePreOrderFailure(requestId, response.message.isNotEmpty ? response.message : '获取订单预处理信息失败', initial: initial);
      }
    } catch (error) {
      _handlePreOrderFailure(requestId, '预处理订单失败：$error', initial: initial);
    }
  }

  void _handlePreOrderFailure(int requestId, String message, {required bool initial}) {
    if (!ref.mounted || requestId != _preOrderRequestId) return;
    state = state.copyWith(
      preOrderInfoAsync: initial && !state.preOrderInfoAsync.hasValue ? AsyncValue.error(message, StackTrace.current) : state.preOrderInfoAsync,
      isPreOrderValidating: false,
      quantityValidationError: message,
    );
  }

  Future<void> refreshAddress() async {
    if (!ref.mounted) return;
    state = state.copyWith(addressAsync: const AsyncValue.loading());
    final memberRepo = ref.read(memberRepositoryProvider);
    final response = await memberRepo.getAddresses(addressId: -1);

    if (!ref.mounted) return;

    if (response.success && response.data != null && response.data!.isNotEmpty) {
      state = state.copyWith(addressAsync: AsyncValue.data(response.data!.first));
    } else {
      state = state.copyWith(addressAsync: const AsyncValue.data(null));
    }
  }

  void setAddress(MemberAddress address) {
    state = state.copyWith(addressAsync: AsyncValue.data(address));
  }

  void increment() {
    if (!state.isQuantityEditable || state.isPreOrderValidating) return;
    final nextQuantity = state.quantity + 1;
    AppLogger.info(
      '积分确认页校验增加数量',
      module: 'points_confirm_order',
      event: 'quantity_increment',
      data: <String, dynamic>{
        'productId': state.productId,
        'userServiceId': state.userServiceId,
        'quantityBefore': state.quantity,
        'quantityCandidate': nextQuantity,
      },
    );
    _fetchPreOrderInfo(quantity: nextQuantity);
  }

  void decrement() {
    if (!state.isQuantityEditable || state.isPreOrderValidating || state.quantity <= 1) return;
    _fetchPreOrderInfo(quantity: state.quantity - 1);
  }

  void setQuantity(int quantity) {
    if (!state.isQuantityEditable || state.isPreOrderValidating || quantity < 1 || quantity == state.quantity) return;
    _fetchPreOrderInfo(quantity: quantity);
  }

  void setRedeemerPhone(String phone) => state = state.copyWith(redeemerPhone: phone);

  /// 提交订单（依据 orderType 分流调用相应 API）
  Future<ApiResponse<PointsOrderSubmitResult>> submitOrder() async {
    if (state.isSubmitting) {
      return ApiResponse.error('订单正在提交中，请勿重复操作');
    }
    if (state.isPreOrderValidating) {
      return ApiResponse.error('订单信息校验中，请稍后再提交');
    }

    final preInfo = state.preOrderInfoAsync.value;
    if (preInfo == null) {
      return ApiResponse.error('预下单信息尚未加载完成');
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final repository = ref.read(pointsRepositoryProvider);
      final pid = int.tryParse(state.productId) ?? 0;
      final quantity = state.quantity;
      final unitPoints = preInfo.product?.points ?? 0;
      final totalPoints = preInfo.totalPoints ?? (unitPoints * quantity);

      final orderType = preInfo.orderType;

      switch (orderType) {
        // 1. 青稞粒/自营积分订单 (SubmitCreditOrder API)
        case OrderType.creditOrder:
          int addressId = 0;
          if (preInfo.recvrType == RecvrType.shipAddress) {
            final address = state.addressAsync.value;
            if (address == null) {
              return ApiResponse.error('请选择收货地址');
            }
            addressId = int.tryParse(address.id ?? '') ?? 0;
          }

          final req = SubmitCreditOrderReq(pid: pid, num: quantity, addressId: addressId, userServiceId: state.userServiceId);

          final resp = await repository.submitCreditOrder(req);
          if (resp.success && resp.data != null) {
            final orderIdInt = resp.data!.primaryOrderId;
            final orderIdStr = orderIdInt != null && orderIdInt > 0 ? orderIdInt.toString() : '';
            if (orderIdStr.isEmpty) {
              return ApiResponse.error('提交订单成功，但未生成有效的订单号');
            }
            return ApiResponse.success(
              PointsOrderSubmitResult(orderId: orderIdStr, orderNo: orderIdStr, pointsDeducted: totalPoints, message: resp.data!.descr),
            );
          } else {
            return ApiResponse.error(resp.data?.descr ?? resp.message.ifEmpty('提交订单失败'));
          }

        // 2. 服务券兑换订单 (SubmitServiceCouponIntegralOrder API)
        case OrderType.serviceCouponBuyOrder:
          final req = SubmitServiceCouponIntegralOrderReq(pid: pid, num: quantity);

          final resp = await repository.submitServiceCouponIntegralOrder(req);
          if (resp.success && resp.data != null) {
            final orderIdStr = resp.data!.orderId != null && resp.data!.orderId! > 0 ? resp.data!.orderId!.toString() : '';
            if (orderIdStr.isEmpty) {
              return ApiResponse.error('提交订单成功，但未生成有效的订单号');
            }
            return ApiResponse.success(
              PointsOrderSubmitResult(orderId: orderIdStr, orderNo: orderIdStr, pointsDeducted: totalPoints, message: resp.data!.descr),
            );
          } else {
            return ApiResponse.error(resp.data?.descr ?? resp.message.ifEmpty('提交订单失败'));
          }

        // 3. 百礼汇第三方积分订单 (SubmitBaiLiHuiOrder API)
        case OrderType.baiLiHuiIntegralOrder:
        default:
          String? mobile;
          String? province;
          String? city;
          String? district;
          String? addressStr;
          String? receiveName;

          if (preInfo.recvrType == RecvrType.shipAddress) {
            final address = state.addressAsync.value;
            if (address == null) {
              return ApiResponse.error('请选择收货地址');
            }
            province = address.province;
            city = address.city;
            district = address.district;
            addressStr = address.detail;
            receiveName = address.name;
            mobile = address.phone;
          } else if (preInfo.recvrType == RecvrType.recvrMobile) {
            if (state.redeemerPhone.trim().isEmpty || state.redeemerPhone.length != 11) {
              return ApiResponse.error('请输入正确的11位手机号');
            }
            mobile = state.redeemerPhone.trim();
          }

          final req = SubmitBaiLiHuiOrderReq(
            pid: pid,
            num: quantity,
            userServiceId: state.userServiceId,
            mobile: mobile,
            province: province,
            city: city,
            district: district,
            address: addressStr,
            receiveName: receiveName,
          );

          final resp = await repository.submitBaiLiHuiOrder(req);
          // ApiResponse.fromJson consumes the flattened `result` field to set resp.success,
          // and strips it before passing the remaining payload (including `orderid`) to the model.
          if (resp.success && resp.data != null) {
            final orderIdStr = resp.data!.orderId?.toString() ?? '';
            if (orderIdStr.isEmpty) {
              return ApiResponse.error('提交订单成功，但未返回订单号');
            }
            return ApiResponse.success(
              PointsOrderSubmitResult(orderId: orderIdStr, orderNo: orderIdStr, pointsDeducted: totalPoints, message: resp.data!.descr),
            );
          } else {
            return ApiResponse.error(resp.data?.descr ?? resp.message.ifEmpty('提交订单失败'));
          }
      }
    } catch (e) {
      return ApiResponse.error('提交订单发生异常: $e');
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }
}

extension _StringExt on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

final pointsConfirmOrderProvider = NotifierProvider.autoDispose.family<PointsConfirmOrderNotifier, PointsConfirmOrderState, PointsConfirmOrderArg>(
  (arg) => PointsConfirmOrderNotifier(arg),
);
