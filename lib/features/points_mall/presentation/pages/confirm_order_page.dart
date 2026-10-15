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
      body: productAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => Center(
          child: AppError(message: '加载失败: $error', onRetry: () => ref.invalidate(serviceProductDetailProvider(productId))),
        ),
        data: (product) => _buildContent(ref, product),
      ),
      bottomNavigationBar: _buildBottomBar(ref),
    );
  }

  Widget _buildContent(WidgetRef ref, ServiceProductDetail product) {
    //测试时先注释掉
    final isGiftCard = product.productType == CreditProductType.giftCard;
    //final isGiftCard = product.productType == CreditProductType.serviceCouponIntegral;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (!isGiftCard) ...[const SliverToBoxAdapter(child: ConfirmOrderHeader()), const SliverToBoxAdapter(child: SizedBox(height: 8))],
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
    // Mock orderId / orderNo（真实场景由 API 返回）
    const mockOrderId = 'DDBH4565465789087654678908765789';
    const mockOrderNo = 'DDBH45674567898908765789';
    GoRouter.of(ref.context).push(
      RouteNames.paymentResult,
      extra: PointsPaymentSuccessData(orderNo: mockOrderNo, transactionNo: mockOrderId, pointsDeducted: totalPoints),
    );
  }
}
