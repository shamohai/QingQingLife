import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/models/share_cart_product_model.dart';
import '../../presentation/providers/service_cart_provider.dart';

/// 购酒享服务结算页
///
/// 数据来源：路由参数 [ServiceCartInitialParams]
/// 结算时调用 submitGroupOrder 接口，成功后返回购物车页。
class ServiceCheckoutPage extends ConsumerWidget {
  final ServiceCartInitialParams params;

  const ServiceCheckoutPage({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(serviceCartProvider(params));

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.servicePageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: const Text('确认订单', style: AppTextStyles.headlineSmall),
        centerTitle: true,
      ),
      body: asyncState.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, _) => Center(
          child: AppError(
            message: '加载失败，请稍后重试',
            onRetry: () => ref.read(serviceCartProvider(params).notifier).retry(),
          ),
        ),
        data: (state) => _buildContent(context, ref, state),
      ),
      bottomNavigationBar: asyncState.when<Widget?>(
        loading: () => null,
        error: (_, _) => null,
        data: (state) => _buildBottomBar(context, state, ref),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ServiceCartState state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md), color: Colors.white),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: AppColors.onSurface),
                    const SizedBox(width: AppSpacing.xs),
                    const Text(
                      '天佑德营销中心',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const Spacer(),
                    const Icon(Icons.expand_more, size: 18, color: AppColors.onSurfaceVariant),
                  ],
                ),
                const Divider(height: 24),
                const Text('商品明细', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                const SizedBox(height: AppSpacing.sm),
                ...state.cartProducts.map((p) => _ProductRow(product: p)),
                const SizedBox(height: AppSpacing.md),
                _SummaryRow(label: '商品合计', amount: state.selectedTotalFormatted),
                _SummaryRow(label: '运费', amount: '¥0.00'),
                const Divider(height: 24),
                _SummaryRow(
                  label: '应付总额',
                  amount: state.selectedTotalFormatted,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ServiceCartState state, WidgetRef ref) {
    final notifier = ref.read(serviceCartProvider(params).notifier);
    final submitting = state.isUpdatingCart == true;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('合计：', style: AppTextStyles.bodySmall),
                  Text(
                    state.selectedTotalFormatted,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.error),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            SizedBox(
              width: 120,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.canSubmit ? AppColors.serviceProjectBlue : AppColors.outlineVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                  elevation: 0,
                ),
                onPressed: (state.canSubmit && !submitting)
                    ? () => _submitOrder(context, ref, state, notifier)
                    : null,
                child: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        '提交订单',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOrder(
    BuildContext context,
    WidgetRef ref,
    ServiceCartState state,
    ServiceCartNotifier notifier,
  ) async {
    // 临时 mock 地址 ID，待地址选择功能上线后替换
    const mockAddressId = 1;

    try {
      final resultObj = await notifier.submitOrder(mockAddressId);
      if (!context.mounted) return;

      if (resultObj.result == 0) {
        // 提交成功，返回购物车页并提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('订单提交成功')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败：${resultObj.descr}')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失败：$e')),
      );
    }
  }
}

class _ProductRow extends StatelessWidget {
  final ShareCartProduct product;
  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: product.image.isNotEmpty
                ? Image.network(
                    product.image,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 48, height: 48, color: AppColors.surfaceVariant),
                  )
                : Container(width: 48, height: 48, color: AppColors.surfaceVariant),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              product.productName,
              style: const TextStyle(fontSize: 12, color: AppColors.onSurface),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'x${product.count}',
            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            product.fullPrice.isNotEmpty ? product.fullPrice : '¥${product.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isTotal;
  const _SummaryRow({required this.label, required this.amount, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isTotal ? AppColors.onSurface : AppColors.onSurfaceVariant)),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? AppColors.error : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
