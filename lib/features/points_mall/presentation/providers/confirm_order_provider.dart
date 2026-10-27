import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../member/domain/repositories/member_repository.dart';
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
  int get hashCode => productId.hashCode ^ userServiceId.hashCode;
}

/// 确认订单页面本地与网络集成状态
class PointsConfirmOrderState {
  final String productId;
  final int userServiceId;
  final int quantity;
  final bool isQuantityEditable;
  final AsyncValue<PreCreditOrderInfoModel> preOrderInfoAsync;
  final AsyncValue<MemberAddress?> addressAsync;
  final String note;
  final String redeemerName;
  final String redeemerPhone;
  final bool isSubmitting;

  const PointsConfirmOrderState({
    required this.productId,
    this.userServiceId = 0,
    this.quantity = 1,
    this.isQuantityEditable = true,
    this.preOrderInfoAsync = const AsyncValue.loading(),
    this.addressAsync = const AsyncValue.data(null),
    this.note = '',
    this.redeemerName = '',
    this.redeemerPhone = '',
    this.isSubmitting = false,
  });

  PointsConfirmOrderState copyWith({
    String? productId,
    int? userServiceId,
    int? quantity,
    bool? isQuantityEditable,
    AsyncValue<PreCreditOrderInfoModel>? preOrderInfoAsync,
    AsyncValue<MemberAddress?>? addressAsync,
    String? note,
    String? redeemerName,
    String? redeemerPhone,
    bool? isSubmitting,
  }) {
    return PointsConfirmOrderState(
      productId: productId ?? this.productId,
      userServiceId: userServiceId ?? this.userServiceId,
      quantity: quantity ?? this.quantity,
      isQuantityEditable: isQuantityEditable ?? this.isQuantityEditable,
      preOrderInfoAsync: preOrderInfoAsync ?? this.preOrderInfoAsync,
      addressAsync: addressAsync ?? this.addressAsync,
      note: note ?? this.note,
      redeemerName: redeemerName ?? this.redeemerName,
      redeemerPhone: redeemerPhone ?? this.redeemerPhone,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class PointsConfirmOrderNotifier extends Notifier<PointsConfirmOrderState> {
  final PointsConfirmOrderArg arg;

  PointsConfirmOrderNotifier(this.arg);

  @override
  PointsConfirmOrderState build() {
    final isEditable = arg.userServiceId == 0;
    Future.microtask(() => _fetchPreOrderInfo());
    return PointsConfirmOrderState(
      productId: arg.productId,
      userServiceId: arg.userServiceId,
      quantity: 1,
      isQuantityEditable: isEditable,
      preOrderInfoAsync: const AsyncValue.loading(),
      addressAsync: const AsyncValue.data(null),
    );
  }

  Future<void> _fetchPreOrderInfo() async {
    if (!ref.mounted) return;
    state = state.copyWith(preOrderInfoAsync: const AsyncValue.loading());

    final repository = ref.read(pointsRepositoryProvider);
    final response = await repository.getPreCreditOrderInfo(userServiceId: state.userServiceId, productId: state.productId, quantity: state.quantity);

    if (!ref.mounted) return;

    if (response.success && response.data != null) {
      final preInfo = response.data!;
      final maxQuantity = preInfo.redeemableQuantity;
      final nextQuantity = maxQuantity > 0 && state.quantity > maxQuantity ? maxQuantity : state.quantity;
      state = state.copyWith(quantity: nextQuantity, preOrderInfoAsync: AsyncValue.data(preInfo));

      if (preInfo.recvrType == RecvrType.shipAddress) {
        await refreshAddress();
      } else {
        state = state.copyWith(addressAsync: const AsyncValue.data(null));
      }
    } else {
      state = state.copyWith(preOrderInfoAsync: AsyncValue.error(response.message.isNotEmpty ? response.message : '获取订单预处理信息失败', StackTrace.current));
    }
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
    if (!state.isQuantityEditable) return;
    final maxQuantity = state.preOrderInfoAsync.value?.redeemableQuantity ?? 0;
    if (maxQuantity > 0 && state.quantity >= maxQuantity) return;
    state = state.copyWith(quantity: state.quantity + 1);
    _fetchPreOrderInfo();
  }

  void decrement() {
    if (!state.isQuantityEditable || state.quantity <= 1) return;
    state = state.copyWith(quantity: state.quantity - 1);
    _fetchPreOrderInfo();
  }

  void setQuantity(int quantity) {
    if (!state.isQuantityEditable || quantity <= 0) return;
    state = state.copyWith(quantity: quantity);
    _fetchPreOrderInfo();
  }

  void setNote(String note) => state = state.copyWith(note: note);
  void setRedeemerName(String name) => state = state.copyWith(redeemerName: name);
  void setRedeemerPhone(String phone) => state = state.copyWith(redeemerPhone: phone);

  /// 提交订单（依据 orderType 分流调用相应 API）
  Future<ApiResponse<PointsOrderSubmitResult>> submitOrder() async {
    if (state.isSubmitting) {
      return ApiResponse.error('订单正在提交中，请勿重复操作');
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

          final req = SubmitCreditOrderReq(pid: pid, num: quantity, addressId: addressId, userServiceId: state.userServiceId, remark: state.note);

          final resp = await repository.submitCreditOrder(req);
          if (resp.success && resp.data != null && (resp.data!.result == 0 || resp.data!.result == 200)) {
            final orderIdStr = resp.data!.orderIds.isNotEmpty ? resp.data!.orderIds.first.toString() : '0';
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
          if (resp.success && resp.data != null && (resp.data!.result == 0 || resp.data!.result == 200)) {
            final orderIdStr = resp.data!.orderId?.toString() ?? '0';
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
            if (state.redeemerName.trim().isEmpty) {
              return ApiResponse.error('请输入接收人姓名');
            }
            if (state.redeemerPhone.trim().isEmpty || state.redeemerPhone.length != 11) {
              return ApiResponse.error('请输入正确的11位手机号');
            }
            receiveName = state.redeemerName.trim();
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
          if (resp.success && resp.data != null && resp.data!.result == 0) {
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
