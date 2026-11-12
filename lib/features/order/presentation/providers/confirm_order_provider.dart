import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../member/domain/repositories/member_repository.dart';
import '../../domain/repositories/order_repository.dart';

class ConfirmOrderState {
  const ConfirmOrderState({
    required this.product,
    required this.address,
    this.quantity = 1,
    this.note = '',
    this.needInvoice = false,
    this.couponName = '新人券 ¥50.00',
    this.couponDiscountCents = 5000,
    this.paymentMethod = '微信支付',
    this.isSubmitting = false,
  });

  final OrderItem product;
  final MemberAddress address;
  final int quantity;
  final String note;
  final bool needInvoice;
  final String? couponName;
  final int couponDiscountCents;
  final String paymentMethod;
  final bool isSubmitting;

  int get productTotalCents => product.totalCents * quantity;
  int get shippingFeeCents => 1000;
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
  ConfirmOrderState build() {
    return ConfirmOrderState(
      product: const OrderItem(
        id: 'confirm-item-1',
        productId: 'product-1',
        skuId: 'sku-1',
        productName: '天佑德电商专供青稞酒特别版本...',
        skuName: '【规格一】天佑德电商专供青稞酒特别版本42度500ml',
        imageUrl: 'assets/images/order/confirm-order-product.png',
        priceCents: 80000,
        quantity: 1,
        totalCents: 80000,
      ),
      address: const MemberAddress(
        id: 'addr_1',
        name: '吴彦祖',
        phone: '130 9876 9987',
        province: '甘肃省',
        city: '兰州市',
        district: '七里河区',
        detail: '兰州中心办公楼801室',
        isDefault: true,
      ),
    );
  }

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
    state = state.copyWith(isSubmitting: true);
    try {
      final response = await ref
          .read(orderRepositoryProvider)
          .createOrder(
            items: [
              OrderItem(
                id: state.product.id,
                productId: state.product.productId,
                skuId: state.product.skuId,
                productName: state.product.productName,
                skuName: state.product.skuName,
                imageUrl: state.product.imageUrl,
                priceCents: state.product.priceCents,
                quantity: state.quantity,
                totalCents: state.product.priceCents * state.quantity,
              ),
            ],
            addressId: state.address.id!,
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
