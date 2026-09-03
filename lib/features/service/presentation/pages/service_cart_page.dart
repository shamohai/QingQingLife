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
class ServiceCartPage extends ConsumerWidget {
  const ServiceCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartDataProvider);
    final selectedTotal = Money.fromCents(state.selectedTotalCents);
    final allSelected = state.allSelected;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: CustomScrollView(
        slivers: [
          _buildTopBar(context),
          _buildBanner(),
          _buildAddressBar(),
          if (state.items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: AppEmpty(message: '购物车是空的，去逛逛吧')),
            )
          else
            _buildCartItems(state.items, ref),
          _buildContinueAddSection(ref),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, state, allSelected, selectedTotal, ref),
    );
  }

  // ─── 顶部导航栏 ────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: SafeArea(
        child: Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 22, color: AppColors.onSurface),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text('购酒享服务', style: AppTextStyles.headlineSmall),
              const Spacer(),
              GestureDetector(
                onTap: () => _showManageDialog(context),
                child: Text(
                  '管理',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Banner 占位区 ─────────────────────────────────────────────────

  Widget _buildBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Center(
          child: Text(
            '活动介绍banner图',
            style: AppTextStyles.labelSmall,
          ),
        ),
      ),
    );
  }

  // ─── 配送地址栏 ─────────────────────────────────────────────────────

  Widget _buildAddressBar() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: AppColors.onSurface),
            const SizedBox(width: AppSpacing.xs),
            const Text(
              '配送至: 天佑德营销中心',
              style: AppTextStyles.bodyMedium,
            ),
            const Spacer(),
            const Icon(Icons.expand_more, size: 20, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // ─── 购物车商品列表 ─────────────────────────────────────────────────

  Widget _buildCartItems(List<CartItem> items, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: _ServiceCartItemRow(
                item: item,
                onToggle: () => ref.read(cartDataProvider.notifier).toggleSelect(item.id),
                onQtyChanged: (qty) => ref.read(cartDataProvider.notifier).updateQuantity(item.id, qty),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  // ─── 继续加购区 ─────────────────────────────────────────────────────

  static const _continueAddProducts = [
    _ContinueAddProduct(
      name: '天佑德电商专供海拔系列2900青稞酒46度500ml',
      priceCents: 20000,
    ),
    _ContinueAddProduct(
      name: '天佑德电商专供海拔系列2900青稞酒46度500ml',
      priceCents: 20000,
    ),
    _ContinueAddProduct(
      name: '天佑德电商专供海拔系列2900青稞酒46度500ml',
      priceCents: 20000,
    ),
  ];

  Widget _buildContinueAddSection(WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
            child: Text('继续加购', style: AppTextStyles.labelMedium),
          ),
          ..._continueAddProducts.map((p) => _ContinueAddItem(product: p)),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  // ─── 底部结算栏 ─────────────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    CartState state,
    bool allSelected,
    Money selectedTotal,
    WidgetRef ref,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md + 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                  activeColor: AppColors.primary,
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
                child: const Center(
                  child: Text('去结算', style: AppTextStyles.labelMedium),
                ),
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
      builder: (ctx) => AlertDialog(
        title: const Text('删除商品'),
        content: const Text('确定要清空购物车吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              context.pop();
              Navigator.pop(ctx);
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

  const _ServiceCartItemRow({
    required this.item,
    required this.onToggle,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          // 复选框
          Checkbox(
            value: item.selected,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          // 商品图片占位
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.surfaceVariant,
            ),
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

  const _QtyControl({
    required this.quantity,
    this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onMinus,
          child: Icon(
            Icons.remove_circle_outline,
            size: 20,
            color: onMinus == null ? AppColors.outlineVariant : AppColors.onSurface,
          ),
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
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          // 图片占位
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.surfaceVariant,
            ),
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
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 18, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}