import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/app_error.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../../../../app/router/route_names.dart';
import '../../../member/domain/repositories/member_repository.dart';
import '../../data/models/points_payment_success_data.dart';
import '../../data/models/pre_credit_order_info_model.dart';
import '../../data/models/service_product_detail_model.dart';
import '../providers/confirm_order_provider.dart';
import '../widgets/confirm_order_bottom_bar.dart';
import '../widgets/confirm_order_header.dart';
import '../widgets/confirm_order_product_card.dart';
import '../widgets/confirm_order_redeemer_form.dart';

class ConfirmOrderPage extends ConsumerWidget {
  final String productId;
  final int? userServiceId;

  const ConfirmOrderPage({super.key, required this.productId, this.userServiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveUserServiceId = userServiceId ?? 0;
    final arg = PointsConfirmOrderArg(productId: productId, userServiceId: effectiveUserServiceId);
    final orderState = ref.watch(pointsConfirmOrderProvider(arg));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: ConfirmOrderNavBar(onBack: () => Navigator.of(context).pop()),
      body: orderState.preOrderInfoAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => Center(
          child: AppError(message: '预下单信息加载失败: $error', onRetry: () => ref.invalidate(pointsConfirmOrderProvider(arg))),
        ),
        data: (preInfo) {
          final product = preInfo.product;
          if (product == null) {
            return const Center(child: AppError(message: '订单商品信息缺失，请返回重试'));
          }
          return _buildContent(context, ref, product, arg, orderState, preInfo);
        },
      ),
      bottomNavigationBar: orderState.preOrderInfoAsync.when(
        data: (preInfo) {
          final product = preInfo.product;
          return product == null ? const SizedBox(height: 56) : _buildBottomBar(ref, arg, product);
        },
        loading: () => const SizedBox(height: 56),
        error: (_, _) => const SizedBox(height: 56),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ServiceProductDetail product,
    PointsConfirmOrderArg arg,
    PointsConfirmOrderState orderState,
    PreCreditOrderInfoModel preInfo,
  ) {
    final recvrType = preInfo.recvrType;

    return Stack(
      children: [
        // 背景渐变及图片
        Positioned.fill(
          child: Column(
            children: [
              Expanded(flex: 50, child: Container(color: const Color(0xFFF3F5F7))),
              Expanded(
                flex: 50,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF3F5F7), Color(0xFFFFFFFF)]),
                    image: DecorationImage(image: AssetImage('assets/images/order/order_bottom_bg.png'), fit: BoxFit.cover, alignment: Alignment.bottomCenter),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 内容滚动区
        Positioned.fill(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. 实物商品展示收货地址卡片
              if (recvrType == RecvrType.shipAddress)
                SliverToBoxAdapter(
                  child: orderState.addressAsync.when(
                    data: (address) => ConfirmOrderHeader(
                      address: address,
                      onAddAddress: () async {
                        await context.push(RouteNames.addressAdd);
                        ref.read(pointsConfirmOrderProvider(arg).notifier).refreshAddress();
                      },
                      onEditAddress: () async {
                        final selected = await context.push<MemberAddress>(RouteNames.address);
                        if (selected != null) {
                          ref.read(pointsConfirmOrderProvider(arg).notifier).setAddress(selected);
                        } else {
                          ref.read(pointsConfirmOrderProvider(arg).notifier).refreshAddress();
                        }
                      },
                    ),
                    loading: () => const ConfirmOrderHeader(isLoading: true),
                    error: (_, _) => ConfirmOrderHeader(
                      onAddAddress: () async {
                        await context.push(RouteNames.addressAdd);
                        ref.read(pointsConfirmOrderProvider(arg).notifier).refreshAddress();
                      },
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // 2. 商品卡片（数量及备注）
              SliverToBoxAdapter(
                child: ConfirmOrderProductCard(
                  product: product,
                  quantity: orderState.quantity,
                  isQuantityEditable: orderState.isQuantityEditable,
                  onIncrement: () => ref.read(pointsConfirmOrderProvider(arg).notifier).increment(),
                  onDecrement: () => ref.read(pointsConfirmOrderProvider(arg).notifier).decrement(),
                  onQuantityChanged: (newQty) {
                    ref.read(pointsConfirmOrderProvider(arg).notifier).setQuantity(newQty);
                  },
                  onNoteChanged: (note) {
                    ref.read(pointsConfirmOrderProvider(arg).notifier).setNote(note);
                  },
                ),
              ),

              // 3. 充值账号/手机号卡密模式展示表单
              if (recvrType == RecvrType.recvrMobile)
                SliverToBoxAdapter(
                  child: ConfirmOrderRedeemerForm(
                    onPhoneChanged: (phone) => ref.read(pointsConfirmOrderProvider(arg).notifier).setRedeemerPhone(phone),
                    onSubmitted: () => _handleSubmit(context, ref, arg),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 78)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(WidgetRef ref, PointsConfirmOrderArg arg, ServiceProductDetail product) {
    final orderState = ref.watch(pointsConfirmOrderProvider(arg));

    return orderState.preOrderInfoAsync.when(
      data: (preInfo) => ConfirmOrderBottomBar(
        product: product,
        quantity: orderState.quantity,
        pointsBalance: preInfo.credit,
        isSubmitting: orderState.isSubmitting,
        onSubmit: () => _handleSubmit(ref.context, ref, arg),
      ),
      loading: () => const SizedBox(height: 56),
      error: (_, _) => const SizedBox(height: 56),
    );
  }

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref, PointsConfirmOrderArg arg) async {
    final notifier = ref.read(pointsConfirmOrderProvider(arg).notifier);
    final submitResult = await notifier.submitOrder();

    if (!context.mounted) return;

    if (submitResult.success && submitResult.data != null) {
      final res = submitResult.data!;
      context.push(
        RouteNames.paymentResult,
        extra: PointsPaymentSuccessData(orderNo: res.orderNo, transactionNo: res.orderId, pointsDeducted: res.pointsDeducted),
      );
    } else {
      final errorMsg = submitResult.message.isNotEmpty ? submitResult.message : '提交订单失败';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }
}
