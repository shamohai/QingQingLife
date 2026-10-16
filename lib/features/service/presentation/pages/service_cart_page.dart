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
            child: AppError(message: '加载失败，请稍后重试', onRetry: () => ref.read(serviceCartProvider(params).notifier).retry()),
          ),
          data: (state) => _buildContent(context, ref, state, params),
        ),
      ),
      bottomNavigationBar: asyncState.when<Widget?>(loading: () => null, error: (_, _) => null, data: (state) => _buildBottomBar(context, state, ref, params)),
    );
  }

  // ─── 内容区（数据已就绪） ─────────────────────────────────────────

  Widget _buildContent(BuildContext context, WidgetRef ref, ServiceCartState state, ServiceCartInitialParams params) {
    return CustomScrollView(
      slivers: [
        _buildTopBar(context),
        _buildBanner(),
        _buildAddressBar(context, state, ref, params),
        _buildContinueAddSection(context, state, ref, params),
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
          final bannerHeight = (constraints.maxWidth - 28) * (230 / 414);
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

  // ─── 配送地址栏 ────────────────────────────────────────────────

  Widget _buildAddressBar(BuildContext context, ServiceCartState state, WidgetRef ref, ServiceCartInitialParams params) {
    final notifier = ref.read(serviceCartProvider(params).notifier);

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
                padding: EdgeInsets.symmetric(vertical: 26),
                child: AppEmpty(message: '暂无商品'),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 3),
                child: Column(
                  children: [
                    for (final item in state.cartProducts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ServiceCartItemRow(
                          product: item,
                          selected: state.selectedMap[item.pid] ?? true,
                          isUpdating: state.cartUpdateInProgress,
                          onToggle: () => notifier.toggleSelect(item.pid),
                          onQtyChanged: (qty) => notifier.addProductToCart(item.pid, qty),
                        ),
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

  Widget _buildContinueAddSection(BuildContext context, ServiceCartState state, WidgetRef ref, ServiceCartInitialParams params) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.sm), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 11, 10, AppSpacing.md),
              child: Row(
                children: [
                  SizedBox(
                    width: 2,
                    height: 16,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.serviceProjectBlue, borderRadius: BorderRadius.all(Radius.circular(2))),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '继续加购',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                ],
              ),
            ),
            if (state.candidateProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: AppEmpty(message: '暂无商品'),
              )
            else
              for (final p in state.candidateProducts)
                _ContinueAddItem(
                  product: p,
                  isUpdating: state.cartUpdateInProgress,
                  onTap: () => _runCartAction(context, () => ref.read(serviceCartProvider(params).notifier).addCandidateProduct(p)),
                ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  // ─── 底部结算栏 ─────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, ServiceCartState state, WidgetRef ref, ServiceCartInitialParams params) {
    final notifier = ref.read(serviceCartProvider(params).notifier);
    final canCheckout = state.canSubmit && state.cartProducts.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(23, 8, 22, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: state.allSelected,
                      onChanged: (v) => notifier.toggleAll(v ?? false),
                      activeColor: AppColors.serviceProjectBlue,
                      shape: const CircleBorder(),
                    ),
                    //const Text('全选', style: AppTextStyles.bodyMedium),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '合计：',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            state.selectedTotalFormatted,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Color(0xFFFE273D)),
                          ),
                        ],
                      ),
                      if (!state.canSubmit && state.verifyMsg.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            state.verifyMsg,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: canCheckout ? () => context.push('/checkout') : null,
                  child: Container(
                    width: 120,
                    height: 47,
                    decoration: BoxDecoration(
                      color: canCheckout ? null : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(AppRadius.round),
                      gradient: canCheckout
                          ? const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [AppColors.serviceTabActive, AppColors.serviceCtaGradStart],
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '结算',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: canCheckout ? Colors.white : AppColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runCartAction(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('购物车更新失败：')));
    }
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
  final bool isUpdating;
  final VoidCallback onToggle;
  final ValueChanged<int> onQtyChanged;

  const _ServiceCartItemRow({required this.product, required this.selected, required this.isUpdating, required this.onToggle, required this.onQtyChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Checkbox(
              value: selected,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.serviceProjectBlue,
              shape: const CircleBorder(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 14),
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: product.image.isNotEmpty
                ? Image.network(
                    product.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: AppColors.surfaceVariant),
                  )
                : Container(width: 80, height: 80, color: AppColors.surfaceVariant),
          ),
          const SizedBox(width: 10),
          // 商品名称 + 价格
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  product.fullPrice.isNotEmpty ? product.fullPrice : _formatPrice(product.price),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.serviceButtonRed),
                ),
              ],
            ),
          ),
          // 数量控制
          _QtyControl(
            quantity: product.count,
            onMinus: !isUpdating && product.count > 0 ? () => onQtyChanged(product.count - 1) : null,
            onPlus: isUpdating ? null : () => onQtyChanged(product.count + 1),
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
  final VoidCallback? onPlus;

  const _QtyControl({required this.quantity, this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QtyButton(icon: Icons.remove, onTap: onMinus, left: true),
        Container(
          width: 34,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(color: Color(0xFFE5E5E5))),
          ),
          child: Text(quantity.toString(), style: const TextStyle(fontSize: 16, color: Colors.black)),
        ),
        _QtyButton(icon: Icons.add, onTap: onPlus, left: false),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool left;

  const _QtyButton({required this.icon, required this.onTap, required this.left});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F8),
          border: Border(
            top: const BorderSide(color: Color(0xFFE5E5E5)),
            bottom: const BorderSide(color: Color(0xFFE5E5E5)),
            left: left ? const BorderSide(color: Color(0xFFE5E5E5)) : BorderSide.none,
            right: left ? BorderSide.none : const BorderSide(color: Color(0xFFE5E5E5)),
          ),
          borderRadius: BorderRadius.horizontal(left: left ? const Radius.circular(7) : Radius.zero, right: left ? Radius.zero : const Radius.circular(7)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: onTap == null ? AppColors.outlineVariant : Colors.black),
      ),
    );
  }
}

// ─── 继续加购商品项（使用 CandidateProduct） ─────────────────────

class _ContinueAddItem extends StatelessWidget {
  final CandidateProduct product;
  final bool isUpdating;
  final VoidCallback onTap;

  const _ContinueAddItem({required this.product, required this.isUpdating, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
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
                    errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: AppColors.surfaceVariant),
                  )
                : Container(width: 80, height: 80, color: AppColors.surfaceVariant),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                if (product.priceDesc.isNotEmpty)
                  Text(
                    product.priceDesc,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.serviceButtonRed),
                  )
                else
                  Text(
                    '¥${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.serviceButtonRed),
                  ),
                if (product.cartNum > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('已加购${product.cartNum}件', style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
          // 圆形加号按钮：InkWell 提供 44x44 点击热区，避免滚动容器中手势竞争
          InkWell(
            onTap: isUpdating ? null : onTap,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: isUpdating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.outlineVariant))
                  : Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: AppColors.serviceButtonRed, shape: BoxShape.circle),
                      child: const Icon(Icons.add, size: 28, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
