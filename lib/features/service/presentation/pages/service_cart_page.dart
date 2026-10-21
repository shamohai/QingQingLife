import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../features/member/domain/repositories/member_repository.dart';
import '../../../../features/member/presentation/providers/member_addresses_provider.dart';
import '../../domain/models/share_cart_candidate_model.dart';
import '../../domain/models/share_cart_product_model.dart';
import '../providers/service_cart_provider.dart';
import '../widgets/service_cart_address_sheet.dart';

/// 购酒享服务购物车页面
///
/// 数据来源：
///  - 路由参数：templateId, headImg, cartId
///  - cartId == 0 时自动调用 createShareCart 获取 shareCartId
///  - 并行拉取 getShareCartProductList + getCandidateProductList
///
/// 状态管理：[serviceCartProvider]（AsyncNotifier，按参数 family 隔离）
class ServiceCartPage extends ConsumerStatefulWidget {
  final int templateId;
  final String headImg;
  final int cartId;

  const ServiceCartPage({super.key, required this.templateId, String? headImg, required this.cartId}) : headImg = headImg ?? '';

  @override
  ConsumerState<ServiceCartPage> createState() => _ServiceCartPageState();
}

class _ServiceCartPageState extends ConsumerState<ServiceCartPage> {
  bool _isManaging = false;
  bool _isSubmittingOrder = false;
  MemberAddress? _selectedAddress;

  @override
  Widget build(BuildContext context) {
    final params = ServiceCartInitialParams(templateId: widget.templateId, headImg: widget.headImg, existingCartId: widget.cartId);
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
              child: widget.headImg.isNotEmpty
                  ? Image.network(
                      widget.headImg,
                      width: double.infinity,
                      height: bannerHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
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

  Widget _buildAddressBar(BuildContext context, ServiceCartState state, WidgetRef ref, ServiceCartInitialParams params) {
    final notifier = ref.read(serviceCartProvider(params).notifier);
    final addresses = ref.watch(memberAddressesProvider).value ?? const <MemberAddress>[];
    final selectedAddress = _selectedAddress ?? _defaultAddress(addresses);

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
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showAddressSheet(context, state, ref, params, selectedAddress),
                      child: Row(
                        children: [
                          const Text('配送至: ', style: AppTextStyles.bodyMedium),
                          const Icon(Icons.location_on, size: 18, color: AppColors.onSurface),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              selectedAddress?.fullAddress ?? '请选择收货地址',
                              style: AppTextStyles.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.expand_more, size: 20, color: AppColors.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                  if (state.cartProducts.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: () => setState(() => _isManaging = !_isManaging),
                      child: Text(_isManaging ? '完成' : '管理', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ],
              ),
            ),
            if (state.cartProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: AppEmpty(message: '暂无商品'),
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
                        isUpdating: state.cartUpdateInProgress,
                        isManaging: _isManaging,
                        onToggle: () => notifier.toggleSelect(item.pid),
                        onQtyChanged: (qty) => notifier.addProductToCart(item.pid, qty),
                        onDelete: () => _runCartAction(context, () => notifier.addProductToCart(item.pid, 0)),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  MemberAddress? _defaultAddress(List<MemberAddress> addresses) {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return null;
  }

  void _showAddressSheet(BuildContext context, ServiceCartState state, WidgetRef ref, ServiceCartInitialParams params, MemberAddress? selectedAddress) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ServiceCartAddressSheet(
        selectedAddress: selectedAddress,
        onSelectAddress: (addr) {
          setState(() => _selectedAddress = addr);
          Navigator.pop(ctx);
        },
        onCreateNewAddress: () {
          Navigator.pop(ctx);
          context.push('/address/add');
        },
      ),
    );
  }

  // ─── 继续加购区 ─────────────────────────────────────────────────

  Widget _buildContinueAddSection(BuildContext context, ServiceCartState state, WidgetRef ref, ServiceCartInitialParams params) {
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
    final addresses = ref.watch(memberAddressesProvider).value ?? const <MemberAddress>[];
    final selectedAddress = _selectedAddress ?? _defaultAddress(addresses);
    final canCheckout = state.canSubmit && state.cartProducts.isNotEmpty && !state.cartUpdateInProgress && !_isSubmittingOrder;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md + 8),
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
                    const Text('全选', style: AppTextStyles.bodyMedium),
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
                            '合计',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            state.selectedTotalFormatted,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.error),
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
                const SizedBox(width: AppSpacing.lg),
                GestureDetector(
                  onTap: canCheckout ? () => _submitOrder(context, ref, params, selectedAddress) : null,
                  child: Container(
                    width: 96,
                    height: 44,
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

  Future<void> _submitOrder(BuildContext context, WidgetRef ref, ServiceCartInitialParams params, MemberAddress? address) async {
    if (_isSubmittingOrder) return;
    final addressId = int.tryParse(address?.id ?? '');
    if (addressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(address == null ? '请选择收货地址' : '收货地址信息无效，请重新选择')));
      return;
    }

    setState(() => _isSubmittingOrder = true);
    try {
      final result = await ref.read(serviceCartProvider(params).notifier).submitOrder(addressId);
      if (!context.mounted) return;
      if (result.result != 0) {
        final message = result.descr.isNotEmpty
            ? result.descr
            : result.guidetext.isNotEmpty
            ? result.guidetext
            : '订单提交失败，请稍后重试';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        return;
      }

      final uri = Uri(path: RouteNames.customerService, queryParameters: {'templateId': widget.templateId.toString()});
      await context.push(uri.toString());
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('订单提交失败：$error')));
    } finally {
      if (mounted) setState(() => _isSubmittingOrder = false);
    }
  }

  Future<void> _runCartAction(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('购物车更新失败：$error')));
    }
  }
}

// ─── 购物车商品行（使用 ShareCartProduct） ─────────────────────────

class _ServiceCartItemRow extends StatelessWidget {
  final ShareCartProduct product;
  final bool selected;
  final bool isUpdating;
  final bool isManaging;
  final VoidCallback onToggle;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onDelete;

  const _ServiceCartItemRow({
    required this.product,
    required this.selected,
    required this.isUpdating,
    required this.isManaging,
    required this.onToggle,
    required this.onQtyChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          if (isManaging)
            IconButton(
              tooltip: '删除商品',
              onPressed: isUpdating ? null : onDelete,
              icon: Image.asset('assets/images/service/service_cart_delete.png', width: 24, height: 24),
            )
          else ...[
            Checkbox(value: selected, onChanged: (_) => onToggle(), activeColor: AppColors.serviceProjectBlue, shape: const CircleBorder()),
            const SizedBox(width: AppSpacing.sm),
          ],
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
          const SizedBox(width: AppSpacing.md),
          // 商品名称单独占行，价格与数量控件并排显示。
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.fullPrice.isNotEmpty ? product.fullPrice : _formatPrice(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _QtyControl(
                      quantity: product.count,
                      onMinus: !isUpdating && product.count > 0 ? () => onQtyChanged(product.count - 1) : null,
                      onPlus: isUpdating ? null : () => onQtyChanged(product.count + 1),
                    ),
                  ],
                ),
              ],
            ),
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
        _QuantityStepButton(icon: Icons.remove_rounded, onTap: onMinus),
        Container(
          width: 34,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border.symmetric(horizontal: BorderSide(color: AppColors.divider)),
          ),
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          ),
        ),
        _QuantityStepButton(icon: Icons.add_rounded, onTap: onPlus),
      ],
    );
  }
}

class _QuantityStepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityStepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.servicePageBackground,
      borderRadius: BorderRadius.horizontal(
        left: icon == Icons.remove_rounded ? const Radius.circular(AppRadius.xs) : Radius.zero,
        right: icon == Icons.add_rounded ? const Radius.circular(AppRadius.xs) : Radius.zero,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.horizontal(
          left: icon == Icons.remove_rounded ? const Radius.circular(AppRadius.xs) : Radius.zero,
          right: icon == Icons.add_rounded ? const Radius.circular(AppRadius.xs) : Radius.zero,
        ),
        child: SizedBox(width: 30, height: 30, child: Icon(icon, size: 18, color: onTap == null ? AppColors.outlineVariant : AppColors.onSurface)),
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
                    errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: AppColors.surfaceVariant),
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface),
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
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.add, size: 18, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
