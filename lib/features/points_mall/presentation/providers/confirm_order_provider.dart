import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 确认订单页面本地状态
///
/// 持有数量、备注及礼品卡兑换人信息，不触及任何网络请求。
/// 商品数据来自 [serviceProductDetailProvider]，积分余额来自 [pointsMallStaticDataProvider]。
class ConfirmOrderState {
  final int quantity;
  final String note;
  final String redeemerName;
  final String redeemerPhone;

  const ConfirmOrderState({this.quantity = 1, this.note = '', this.redeemerName = '', this.redeemerPhone = ''});

  ConfirmOrderState copyWith({int? quantity, String? note, String? redeemerName, String? redeemerPhone}) {
    return ConfirmOrderState(
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      redeemerName: redeemerName ?? this.redeemerName,
      redeemerPhone: redeemerPhone ?? this.redeemerPhone,
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

  void setQuantity(int quantity) {
    if (quantity > 0) {
      state = state.copyWith(quantity: quantity);
    }
  }

  void setNote(String note) => state = state.copyWith(note: note);

  set redeemerName(String value) => state = state.copyWith(redeemerName: value);
  set redeemerPhone(String value) => state = state.copyWith(redeemerPhone: value);
}

final confirmOrderProvider = NotifierProvider<ConfirmOrderNotifier, ConfirmOrderState>(ConfirmOrderNotifier.new);
