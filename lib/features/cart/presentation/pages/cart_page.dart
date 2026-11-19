import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/cart_page_models.dart';
import '../providers/cart_page_provider.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_design_tokens.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_page_header.dart';
import '../widgets/cart_recommendation_card.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartPageProvider);
    final controller = ref.read(cartPageProvider.notifier);

    return Scaffold(
      backgroundColor: CartDesignTokens.pageBackground,
      bottomNavigationBar: state.items.isEmpty
          ? null
          : CartBottomBar(
              state: state,
              onToggleAll: controller.toggleAll,
              onPrimaryAction: () => state.isManaging ? _confirmDelete(context, ref) : _showCheckoutSummary(context, state),
              onClearAll: () => _confirmClearAll(context, ref),
            ),
      body: Column(
        children: [
          CartPageHeader(
            address: state.selectedAddress,
            isManaging: state.isManaging,
            hasItems: state.items.isNotEmpty,
            onBack: () => _goBack(context),
            onAddressTap: () => _showAddressSelector(context, ref, state),
            onManageTap: controller.toggleManaging,
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
                SliverToBoxAdapter(
                  child: state.items.isEmpty
                      ? const _EmptyCartPanel()
                      : _CartItemsPanel(
                          items: state.items,
                          isManaging: state.isManaging,
                          onToggle: controller.toggleItem,
                          onQuantityChanged: controller.updateQuantity,
                          onSwipeDelete: (id) => _swipeDelete(ref, id),
                        ),
                ),
                const SliverToBoxAdapter(child: _RecommendationHeading()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.compactPageMargin, 0, AppSpacing.compactPageMargin, AppSpacing.xl),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.crossAxisExtent - AppSpacing.compactItemGap) / 2;
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.compactItemGap,
                          mainAxisSpacing: AppSpacing.md,
                          mainAxisExtent: cardWidth + 164,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = state.recommendations[index];
                          return CartRecommendationCard(
                            product: product,
                            onAdd: () {
                              controller.addRecommendation(product);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(const SnackBar(content: Text('已加入购物车'), duration: Duration(milliseconds: 900)));
                            },
                          );
                        }, childCount: state.recommendations.length),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.go('/');
  }

  Future<void> _showAddressSelector(BuildContext context, WidgetRef ref, CartPageState state) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '配送地址',
                style: TextStyle(color: Color(0xFF111111), fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...state.addresses.map(
                (address) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    address == state.selectedAddress ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: CartDesignTokens.primary,
                  ),
                  title: Text(address, style: const TextStyle(fontSize: 14)),
                  onTap: () {
                    ref.read(cartPageProvider.notifier).setAddress(address);
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showDeleteConfirmation(context, '你确定要删除勾选商品吗？');

    if (confirmed == true) {
      ref.read(cartPageProvider.notifier).deleteSelected();
    }
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showDeleteConfirmation(context, '确定要清空购物车吗？');

    if (confirmed == true) {
      ref.read(cartPageProvider.notifier).clearAll();
    }
  }

  Future<bool> _swipeDelete(WidgetRef ref, String id) async {
    ref.read(cartPageProvider.notifier).deleteItem(id);
    return true;
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 414),
          child: SizedBox(
            height: 207,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black, fontSize: 20, height: 1.4, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, color: CartDesignTokens.faint),
                SizedBox(
                  height: 70,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          style: TextButton.styleFrom(foregroundColor: CartDesignTokens.muted, shape: const RoundedRectangleBorder()),
                          child: const Text('取消', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const VerticalDivider(width: 1, color: CartDesignTokens.faint),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: TextButton.styleFrom(foregroundColor: CartDesignTokens.primary, shape: const RoundedRectangleBorder()),
                          child: const Text('确认', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCheckoutSummary(BuildContext context, CartPageState state) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) => _CheckoutSummarySheet(
        state: state,
        onConfirm: () {
          Navigator.pop(sheetContext);
          context.push(RouteNames.mallConfirmOrder);
        },
      ),
    );
  }
}

class _CartItemsPanel extends StatelessWidget {
  const _CartItemsPanel({required this.items, required this.isManaging, required this.onToggle, required this.onQuantityChanged, required this.onSwipeDelete});

  final List<CartDisplayItem> items;
  final bool isManaging;
  final ValueChanged<String> onToggle;
  final void Function(String id, int quantity) onQuantityChanged;
  final Future<bool?> Function(String id) onSwipeDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.compactPageMargin),
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(CartDesignTokens.panelRadius)),
      child: Column(
        children: List.generate(items.length * 2 - 1, (index) {
          if (index.isOdd) return const SizedBox(height: AppSpacing.md);
          final item = items[index ~/ 2];
          final card = CartItemCard(item: item, onToggle: () => onToggle(item.id), onQuantityChanged: (quantity) => onQuantityChanged(item.id, quantity));

          if (isManaging) return card;

          return Dismissible(
            key: ValueKey('swipe-${item.id}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => onSwipeDelete(item.id),
            background: const _SwipeDeleteBackground(),
            secondaryBackground: const _SwipeDeleteBackground(),
            child: card,
          );
        }),
      ),
    );
  }
}

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 22),
      decoration: BoxDecoration(color: CartDesignTokens.dangerSurface, borderRadius: BorderRadius.circular(CartDesignTokens.cardRadius)),
      child: Semantics(
        label: '删除商品',
        child: const Icon(Icons.delete_outline_rounded, color: CartDesignTokens.danger, size: 28),
      ),
    );
  }
}

class _EmptyCartPanel extends StatelessWidget {
  const _EmptyCartPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.compactPageMargin),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(CartDesignTokens.panelRadius)),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 48, color: Color(0xFFB4B8C0)),
          SizedBox(height: AppSpacing.md),
          Text(
            '购物车还是空的',
            style: TextStyle(color: Color(0xFF555555), fontSize: 15, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: AppSpacing.xs),
          Text('看看下面为你推荐的商品吧', style: TextStyle(color: CartDesignTokens.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RecommendationHeading extends StatelessWidget {
  const _RecommendationHeading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 42, child: Divider(color: CartDesignTokens.faint)),
          const SizedBox(width: 14),
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: CartDesignTokens.price, shape: BoxShape.circle),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 6),
          const Text(
            '猜你喜欢',
            style: TextStyle(color: Color(0xFF111111), fontSize: 18, height: 1, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 14),
          const SizedBox(width: 42, child: Divider(color: CartDesignTokens.faint)),
        ],
      ),
    );
  }
}

class _CheckoutSummarySheet extends StatelessWidget {
  const _CheckoutSummarySheet({required this.state, required this.onConfirm});

  final CartPageState state;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    String money(int cents) => '¥${(cents / 100).toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('结算预览', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          _SummaryRow(label: '商品数量', value: '${state.selectedQuantity} 件'),
          _SummaryRow(label: '商品金额', value: money(state.selectedSubtotalCents)),
          _SummaryRow(label: '优惠金额', value: '-${money(state.selectedSavingsCents)}'),
          const Divider(height: 28),
          _SummaryRow(label: '应付合计', value: money(state.selectedPayableCents), emphasized: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [CartDesignTokens.primary, CartDesignTokens.primaryEnd]),
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextButton(
                onPressed: onConfirm,
                child: const Text('确认', style: TextStyle(color: Colors.white, fontSize: 17)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasized = false});

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: emphasized ? const Color(0xFF111111) : CartDesignTokens.muted,
              fontSize: emphasized ? 16 : 14,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: emphasized ? CartDesignTokens.summary : const Color(0xFF333333),
              fontSize: emphasized ? 21 : 14,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
