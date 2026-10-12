import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

/// 购酒享服务购物车页面
///
/// 与 [CartPage] 不是同一个页面，从特色商城「购酒享服务」分类的
/// 「去购买」按钮跳转而来。共享 [cartDataProvider] 数据源。
///
/// 路由参数：
/// - templateId: 模板 ID
/// - headImg: 头图 URL（通过 #sym: 前缀传递）
/// - cartId: 购物车 ID（通过 #sym: 前缀传递）
class ServiceCartPage extends ConsumerWidget {
  final int templateId;
  final String headImg;
  final int cartId;

  const ServiceCartPage({super.key, required this.templateId, String? headImg, required this.cartId}) : headImg = headImg ?? '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartDataProvider);
    final selectedTotal = Money.fromCents(state.selectedTotalCents);
    final allSelected = state.allSelected;

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            _buildTopBar(context),
            _buildBanner(),
            _buildAddressBar(context, state.items, ref),
            _buildContinueAddSection(ref),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, state, allSelected, selectedTotal, ref),
    );
  }

  // ─── 顶部导航栏 ────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: SafeArea(
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
      ),
    );
  }

  // ─── Banner 占位区 ─────────────────────────────────────────────────

  Widget _buildBanner() {
    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          // 使用图片实际宽高比自适应高度，限制最大高度 150dp
          const maxHeight = 230.0;
          // 假设图片为标准 1080×554，实际根据 headImg 动态计算（这里取 0.5125 比例 = 1080×554）
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

  // ─── 配送地址栏 ─────────────────────────────────────────────────────

  Widget _buildAddressBar(BuildContext context, List<CartItem> items, WidgetRef ref) {
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
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: AppEmpty(message: '购物车是空的，去逛逛吧'),
              )
            else
              _buildCartItems(items, ref),
          ],
        ),
      ),
    );
  }

  // ─── 购物车商品列表 ─────────────────────────────────────────────────

  Widget _buildCartItems(List<CartItem> items, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        children: [
          for (final item in items)
            _ServiceCartItemRow(
              item: item,
              onToggle: () => ref.read(cartDataProvider.notifier).toggleSelect(item.id),
              onQtyChanged: (qty) => ref.read(cartDataProvider.notifier).updateQuantity(item.id, qty),
            ),
        ],
      ),
    );
  }

  // ─── 继续加购区 ─────────────────────────────────────────────────────

  static const _continueAddProducts = [
    _ContinueAddProduct(name: '天佑德电商专供海拔系列2900青稞酒46度500ml', priceCents: 20000),
    _ContinueAddProduct(name: '天佑德电商专供海拔系列2900青稞酒46度500ml', priceCents: 20000),
    _ContinueAddProduct(name: '天佑德电商专供海拔系列2900青稞酒46度500ml', priceCents: 20000),
  ];

  Widget _buildContinueAddSection(WidgetRef ref) {
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
            ..._continueAddProducts.map((p) => _ContinueAddItem(product: p)),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  // ─── 底部结算栏 ─────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, CartState state, bool allSelected, Money selectedTotal, WidgetRef ref) {
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
                  value: allSelected,
                  onChanged: (v) => ref.read(cartDataProvider.notifier).toggleAll(v),
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
                  selectedTotal.format(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),
            GestureDetector(
              onTap: () => context.push('/checkout'),
              child: Container(
                width: 96,
                height: 44,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.sm)),
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

// ─── 购物车商品行（无左侧 checkbox，复用 CartItemCard 风格）────────────

class _ServiceCartItemRow extends StatelessWidget {
  final CartItem item;
  final VoidCallback onToggle;
  final ValueChanged<int> onQtyChanged;

  const _ServiceCartItemRow({required this.item, required this.onToggle, required this.onQtyChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // 复选框
          Checkbox(value: item.selected, onChanged: (_) => onToggle(), activeColor: AppColors.serviceProjectBlue, shape: const CircleBorder()),
          const SizedBox(width: AppSpacing.sm),
          // 商品图片占位
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(width: 80, height: 80, color: AppColors.surfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          // 商品名称 + 价格
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  Money.fromCents(item.priceCents).format(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error),
                ),
              ],
            ),
          ),
          // 数量控制：- 数字 +
          _QtyControl(
            quantity: item.quantity,
            onMinus: item.quantity > 1 ? () => onQtyChanged(item.quantity - 1) : null,
            onPlus: () => onQtyChanged(item.quantity + 1),
          ),
        ],
      ),
    );
  }
}

// ─── 数量控制控件 ─────────────────────────────────────────────────────

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

// ─── 继续加购商品项 ───────────────────────────────────────────────────

class _ContinueAddProduct {
  final String name;
  final int priceCents;
  const _ContinueAddProduct({required this.name, required this.priceCents});
}

class _ContinueAddItem extends StatelessWidget {
  final _ContinueAddProduct product;

  const _ContinueAddItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // 图片占位
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(width: 80, height: 80, color: AppColors.surfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  Money.fromCents(product.priceCents).format(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error),
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
