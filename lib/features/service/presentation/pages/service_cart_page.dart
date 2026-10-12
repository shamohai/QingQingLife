import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/models/share_cart_candidate_model.dart';
import '../../domain/models/share_cart_product_model.dart';
import '../providers/service_cart_provider.dart';

/// 购酒享服务购物车页面
///
/// 数据来源：
///  - 路由参数：templateId, headImg, cartId
///  - cartId == 0 时自动调用 createShareCart 获取 shareCartId
///  - 并行拉取 getShareCartProductList + getCandidateProductList
///
/// 状态管理：[serviceCartProvider]（AsyncNotifier，按参数 family 隔离）
class ServiceCartPage extends ConsumerWidget {
  final int templateId;
  final String headImg;
  final int cartId;

  const ServiceCartPage({super.key, required this.templateId, String? headImg, required this.cartId}) : headImg = headImg ?? '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ServiceCartInitialParams(templateId: templateId, headImg: headImg, existingCartId: cartId);
    final asyncState = ref.watch(serviceCartProvider(params));

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      body: SafeArea(
        bottom: false,
        child: asyncState.when(
          loading: () => const Center(child: AppLoading()),
          error: (error, _) => Center(
            child: AppError(message: '加载失败，请稍后重试', onRetry: () => ref.invalidate(serviceCartProvider(params))),
          ),
          data: (state) => _buildContent(context, ref, state),
        ),
      ),
      bottomNavigationBar: asyncState.when<Widget?>(loading: () => null, error: (_, _) => null, data: (state) => _buildBottomBar(context, state, ref)),
    );
  }

  // ─── 内容区（数据已就绪） ─────────────────────────────────────────

  Widget _buildContent(BuildContext context, WidgetRef ref, ServiceCartState state) {
    return CustomScrollView(
      slivers: [
        _buildTopBar(context),
        _buildBanner(),
        _buildAddressBar(context, state, ref),
        _buildContinueAddSection(state, ref),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }

  // ─── 顶部导航栏 ───────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.servicePageBackground,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 22, color: AppColors.onSurface),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('购酒享服务', style: AppTextStyles.headlineSmall),
          ],
        ),
      ),
    );
  }

  // ─── Banner ──────────────────────────────────────────────────────

  Widget _buildBanner() {
    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          const maxHeight = 230.0;
          final aspectRatio = 554 / 1080;
          final calculatedHeight = screenWidth * aspectRatio;
          final bannerHeight = calculatedHeight > maxHeight ? maxHeight : calculatedHeight;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: headImg.isNotEmpty
                  ? Image.network(
                      headImg,
                      width: double.infinity,
                      height: bannerHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Center(child: Text('活动介绍banner图', style: AppTextStyles.labelSmall)),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceVariant,
                      child: const Center(child: Text('活动介绍banner图', style: AppTextStyles.labelSmall)),
                    ),
            ),
          );
        },
      ),
    );
  }

  // ─── 配送地址栏 + 购物车商品列表 ────────────────────────────────

  Widget _buildAddressBar(BuildContext context, ServiceCartState state, WidgetRef ref) {
    final notifier = ref.read(serviceCartProvider(ServiceCartInitialParams(templateId: templateId, headImg: headImg, existingCartId: cartId)).notifier);

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  const Text('配送至: ', style: AppTextStyles.bodyMedium),
                  const Icon(Icons.location_on, size: 18, color: AppColors.onSurface),
                  const SizedBox(width: AppSpacing.xs),
                  const Text('天佑德营销中心', style: AppTextStyles.bodyMedium),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.expand_more, size: 20, color: AppColors.onSurfaceVariant),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showManageDialog(context),
                    child: Text('管理', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            if (state.cartProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: AppEmpty(message: '购物车是空的，去逛逛吧'),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  children: [
                    for (final item in state.cartProducts)
                      _ServiceCartItemRow(
                        product: item,
                        selected: state.selectedMap[item.pid] ?? true,
                        onToggle: () => notifier.toggleSelect(item.pid),
                        onQtyChanged: (_) => notifier.refreshCartProducts(),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── 继续加购区 ─────────────────────────────────────────────────

  Widget _buildContinueAddSection(ServiceCartState state, WidgetRef ref) {
    if (state.candidateProducts.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
              child: Row(
                children: [
                  SizedBox(
                    width: 3,
                    height: 16,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.serviceProjectBlue, borderRadius: BorderRadius.all(Radius.circular(2))),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '继续加购',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                  ),
                ],
              ),
            ),
            for (final p in state.candidateProducts) _ContinueAddItem(product: p),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  // ─── 底部结算栏 ─────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, ServiceCartState state, WidgetRef ref) {
    final notifier = ref.read(serviceCartProvider(ServiceCartInitialParams(templateId: templateId, headImg: headImg, existingCartId: cartId)).notifier);

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
            Row(
              children: [
                Checkbox(
                  value: state.allSelected,
                  onChanged: (v) => notifier.toggleAll(v ?? false),
                  activeColor: AppColors.serviceProjectBlue,
                  shape: const CircleBorder(),
                ),
                const Text('全选', style: AppTextStyles.bodyMedium),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('合计', style: AppTextStyles.bodySmall),
                Text(
                  state.selectedTotalFormatted,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),
            GestureDetector(
              onTap: state.canSubmit
                  ? () {
                      if (state.verifyMsg.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.verifyMsg)));
                      } else {
                        context.push('/checkout');
                      }
                    }
                  : null,
              child: Container(
                width: 96,
                height: 44,
                decoration: BoxDecoration(
                  color: state.canSubmit ? AppColors.primary : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Center(child: Text('去结算', style: AppTextStyles.labelMedium)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除商品'),
        content: const Text('确定要清空购物车吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pop();
            },
            child: const Text('清空', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── 购物车商品行（使用 ShareCartProduct） ─────────────────────────

class _ServiceCartItemRow extends StatelessWidget {
  final ShareCartProduct product;
  final bool selected;
  final VoidCallback onToggle;
  final ValueChanged<int> onQtyChanged;

  const _ServiceCartItemRow({required this.product, required this.selected, required this.onToggle, required this.onQtyChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Checkbox(value: selected, onChanged: (_) => onToggle(), activeColor: AppColors.serviceProjectBlue, shape: const CircleBorder()),
          const SizedBox(width: AppSpacing.sm),
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: product.image.isNotEmpty
                ? Image.network(
                    product.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceVariant),
                  )
                : Container(width: 80, height: 80, color: AppColors.surfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          // 商品名称 + 价格
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  product.fullPrice.isNotEmpty ? product.fullPrice : _formatPrice(product.price),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error),
                ),
              ],
            ),
          ),
          // 数量控制
          _QtyControl(
            quantity: product.count,
            onMinus: product.count > 1 ? () => onQtyChanged(product.count - 1) : null,
            onPlus: () => onQtyChanged(product.count + 1),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double priceYuan) {
    final cents = (priceYuan * 100).round();
    return '¥${(cents / 100).toStringAsFixed(2)}';
  }
}

// ─── 数量控制控件 ─────────────────────────────────────────────────

class _QtyControl extends StatelessWidget {
  final int quantity;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  const _QtyControl({required this.quantity, this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onMinus,
          child: Icon(Icons.remove_circle_outline, size: 20, color: onMinus == null ? AppColors.outlineVariant : AppColors.onSurface),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(quantity.toString(), style: const TextStyle(fontSize: 14, color: AppColors.onSurface)),
        ),
        GestureDetector(
          onTap: onPlus,
          child: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.onSurface),
        ),
      ],
    );
  }
}

// ─── 继续加购商品项（使用 CandidateProduct） ─────────────────────

class _ContinueAddItem extends StatelessWidget {
  final CandidateProduct product;

  const _ContinueAddItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // 图片
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: product.imgUrl.isNotEmpty
                ? Image.network(
                    product.imgUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceVariant),
                  )
                : Container(width: 80, height: 80, color: AppColors.surfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (product.priceDesc.isNotEmpty)
                  Text(
                    product.priceDesc,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error),
                  )
                else
                  Text(
                    '¥${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error),
                  ),
                if (product.cartNum > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('已加购${product.cartNum}件', style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
          // 圆形加号按钮
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.add, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
