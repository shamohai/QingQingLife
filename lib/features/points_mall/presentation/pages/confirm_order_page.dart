import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/app_error.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../../../../app/router/route_names.dart';
import '../../data/models/get_recommend_product_list_model.dart';
import '../../data/models/points_payment_success_data.dart';
import '../../data/models/service_product_detail_model.dart';
import '../providers/confirm_order_provider.dart';
import '../providers/points_mall_paging_providers.dart';
import '../providers/service_product_detail_provider.dart';
import '../widgets/confirm_order_bottom_bar.dart';
import '../widgets/confirm_order_header.dart';
import '../widgets/confirm_order_product_card.dart';
import '../widgets/confirm_order_redeemer_form.dart';

class ConfirmOrderPage extends ConsumerWidget {
  final String productId;
  const ConfirmOrderPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(serviceProductDetailProvider(productId));
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: ConfirmOrderNavBar(onBack: () => Navigator.of(context).pop()),
      body: productAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => Center(
          child: AppError(message: '加载失败: $error', onRetry: () => ref.invalidate(serviceProductDetailProvider(productId))),
        ),
        data: (product) => _buildContent(context, ref, product),
      ),
      bottomNavigationBar: _buildBottomBar(ref),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ServiceProductDetail product) {
    //测试时使用
    //final isGiftCard = product.productType == CreditProductType.giftCard;
    final isGiftCard = product.productType == CreditProductType.serviceCouponIntegral;
    return Stack(
      children: [
        // 页面背景：上半部 50% 纯色 #F3F5F7（无渐变），下半部 50% 背景图加图层
        Positioned.fill(
          child: Column(
            children: [
              // 上半部 50% 纯背景色 #F3F5F7，无渐变
              Expanded(
                flex: 50,
                child: Container(
                  color: const Color(0xFFF3F5F7),
                ),
              ),
              // 下半部 50% 背景图加图层
              Expanded(
                flex: 50,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF3F5F7), Color(0xFFFFFFFF)],
                    ),
                    image: DecorationImage(
                      image: AssetImage('assets/images/order/order_bottom_bg.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 前景内容区
        Positioned.fill(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (!isGiftCard) const SliverToBoxAdapter(child: ConfirmOrderHeader()),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, _) {
                    final notifier = ref.watch(confirmOrderProvider);
                    return ConfirmOrderProductCard(
                      product: product,
                      quantity: notifier.quantity,
                      onIncrement: () => ref.read(confirmOrderProvider.notifier).increment(),
                      onDecrement: () => ref.read(confirmOrderProvider.notifier).decrement(),
                      onQuantityChanged: (newQty) {
                        ref.read(confirmOrderProvider.notifier).setQuantity(newQty);
                      },
                    );
                  },
                ),
              ),
              if (isGiftCard) SliverToBoxAdapter(child: ConfirmOrderRedeemerForm(onSubmitted: () => _handleSubmit(ref, product))),
              const SliverToBoxAdapter(child: SizedBox(height: 78)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(WidgetRef ref) {
    final productAsync = ref.watch(serviceProductDetailProvider(productId));
    final pointsAsync = ref.watch(pointsMallStaticDataProvider);
    return productAsync.when(
      data: (product) => pointsAsync.when(
        data: (d) => ConfirmOrderBottomBar(product: product, pointsBalance: d.currentPoints, onSubmit: () => _handleSubmit(ref, product)),
        loading: () => const SizedBox(height: 56),
        error: (_, _) => const SizedBox(height: 56),
      ),
      loading: () => const SizedBox(height: 56),
      error: (_, _) => const SizedBox(height: 56),
    );
  }

  void _handleSubmit(WidgetRef ref, ServiceProductDetail product) {
    final quantity = ref.read(confirmOrderProvider).quantity;
    final totalPoints = product.points * quantity;
    const mockOrderId = 'DDBH4565465789087654678908765789';
    const mockOrderNo = 'DDBH45674567898908765789';
    GoRouter.of(ref.context).push(
      RouteNames.paymentResult,
      extra: PointsPaymentSuccessData(orderNo: mockOrderNo, transactionNo: mockOrderId, pointsDeducted: totalPoints),
    );
  }
}
