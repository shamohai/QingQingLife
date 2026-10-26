import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../member/domain/repositories/member_repository.dart';
import '../../data/models/pre_credit_order_info_model.dart';

/// 确认订单页面参数
class PointsConfirmOrderArg {
  final String productId;
  final int userServiceId;

  const PointsConfirmOrderArg({
    required this.productId,
    this.userServiceId = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointsConfirmOrderArg &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          userServiceId == other.userServiceId;

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
    final response = await repository.getPreCreditOrderInfo(
      userServiceId: state.userServiceId,
      productId: state.productId,
      quantity: state.quantity,
    );

    if (!ref.mounted) return;

    if (response.success && response.data != null) {
      final preInfo = response.data!;
      state = state.copyWith(preOrderInfoAsync: AsyncValue.data(preInfo));

      if (preInfo.recvrType == RecvrType.shipAddress) {
        await refreshAddress();
      } else {
        state = state.copyWith(addressAsync: const AsyncValue.data(null));
      }
    } else {
      state = state.copyWith(
        preOrderInfoAsync: AsyncValue.error(
          response.message.isNotEmpty ? response.message : '获取订单预处理信息失败',
          StackTrace.current,
        ),
      );
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
}

final pointsConfirmOrderProvider = NotifierProvider.autoDispose.family<PointsConfirmOrderNotifier, PointsConfirmOrderState, PointsConfirmOrderArg>(
  (arg) => PointsConfirmOrderNotifier(arg),
);
