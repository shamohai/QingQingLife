import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../member/domain/repositories/member_repository.dart';
import '../../domain/repositories/order_repository.dart';

class ConfirmOrderState {
  const ConfirmOrderState({
    this.product,
    this.address,
    this.quantity = 1,
    this.note = '',
    this.needInvoice = false,
    this.couponName,
    this.couponDiscountCents = 0,
    this.paymentMethod = '微信支付',
    this.isSubmitting = false,
  });

  /// 结算商品与收货地址由购物车/商品详情传入，未传入时为空，页面展示空态且禁止提交。
  final OrderItem? product;
  final MemberAddress? address;
  final int quantity;
  final String note;
  final bool needInvoice;
  final String? couponName;
  final int couponDiscountCents;
  final String paymentMethod;
  final bool isSubmitting;

  bool get canSubmit => product != null && address?.id != null && !isSubmitting;

  int get productTotalCents => (product?.priceCents ?? 0) * quantity;

  /// 运费由后端计算，客户端不做估算。
  int get shippingFeeCents => 0;

  int get payableCents {
    final value = productTotalCents + shippingFeeCents - couponDiscountCents;
    return value < 0 ? 0 : value;
  }

  ConfirmOrderState copyWith({
    OrderItem? product,
    MemberAddress? address,
    int? quantity,
    String? note,
    bool? needInvoice,
    String? couponName,
    int? couponDiscountCents,
    bool clearCoupon = false,
    String? paymentMethod,
    bool? isSubmitting,
  }) {
    return ConfirmOrderState(
      product: product ?? this.product,
      address: address ?? this.address,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      needInvoice: needInvoice ?? this.needInvoice,
      couponName: clearCoupon ? null : (couponName ?? this.couponName),
      couponDiscountCents: clearCoupon ? 0 : (couponDiscountCents ?? this.couponDiscountCents),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ConfirmOrderNotifier extends Notifier<ConfirmOrderState> {
  @override
  ConfirmOrderState build() => const ConfirmOrderState();

  void increment() => state = state.copyWith(quantity: state.quantity + 1);

  void decrement() {
    if (state.quantity > 1) {
      state = state.copyWith(quantity: state.quantity - 1);
    }
  }

  void setNote(String value) => state = state.copyWith(note: value);
  void setAddress(MemberAddress value) => state = state.copyWith(address: value);
  void setNeedInvoice(bool value) => state = state.copyWith(needInvoice: value);
  void setPaymentMethod(String value) => state = state.copyWith(paymentMethod: value);

  void selectCoupon({required String name, required int discountCents}) {
    state = state.copyWith(couponName: name, couponDiscountCents: discountCents);
  }

  void clearCoupon() => state = state.copyWith(clearCoupon: true);

  Future<ApiResponse<OrderCreateResult>> submit() async {
    final product = state.product;
    final addressId = state.address?.id;
    if (product == null || addressId == null) {
      return ApiResponse.error('请选择商品与收货地址');
    }
    state = state.copyWith(isSubmitting: true);
    try {
      final response = await ref
          .read(orderRepositoryProvider)
          .createOrder(
            items: [
              OrderItem(
                id: product.id,
                productId: product.productId,
                skuId: product.skuId,
                productName: product.productName,
                skuName: product.skuName,
                imageUrl: product.imageUrl,
                priceCents: product.priceCents,
                quantity: state.quantity,
                totalCents: product.priceCents * state.quantity,
              ),
            ],
            addressId: addressId,
            shippingFeeCents: state.shippingFeeCents,
            couponCode: state.couponName,
            remark: state.note.isEmpty ? null : state.note,
          );
      state = state.copyWith(isSubmitting: false);
      return response;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      return ApiResponse.error('订单提交失败，请稍后重试');
    }
  }
}

final confirmOrderProvider = NotifierProvider<ConfirmOrderNotifier, ConfirmOrderState>(ConfirmOrderNotifier.new);
