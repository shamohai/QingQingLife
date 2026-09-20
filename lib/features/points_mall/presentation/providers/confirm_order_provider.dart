import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 确认订单页面本地状态
///
/// 持有数量与备注信息，不触及任何网络请求。
/// 商品数据来自 [serviceProductDetailProvider]，积分余额来自 [pointsMallStaticDataProvider]。
class ConfirmOrderState {
  final int quantity;
  final String note;

  const ConfirmOrderState({this.quantity = 1, this.note = ''});

  ConfirmOrderState copyWith({int? quantity, String? note}) {
    return ConfirmOrderState(
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}

class ConfirmOrderNotifier extends Notifier<ConfirmOrderState> {
  @override
  ConfirmOrderState build() => const ConfirmOrderState();

  void increment() => state = state.copyWith(quantity: state.quantity + 1);
  void decrement() {
    if (state.quantity > 1) state = state.copyWith(quantity: state.quantity - 1);
  }
  void setNote(String note) => state = state.copyWith(note: note);
}

final confirmOrderProvider =
    NotifierProvider<ConfirmOrderNotifier, ConfirmOrderState>(ConfirmOrderNotifier.new);