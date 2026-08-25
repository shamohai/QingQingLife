import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_empty.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_bottom_bar.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartDataProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverSafeArea(
            sliver: SliverToBoxAdapter(
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Text('购物车', style: AppTextStyles.headlineSmall),
                    const Spacer(),
                    if (state.items.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showManageDialog(context, ref),
                        child: Text(
                          '管理',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // 优惠券横幅
          if (state.couponCode != null)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      size: 18,
                      color: Color(0xFFFF8F00),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '已使用优惠券：\${state.couponCode}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 商品列表
          SliverFillRemaining(
            hasScrollBody: state.items.isNotEmpty,
            child: state.items.isEmpty
                ? const Center(child: AppEmpty(message: '购物车是空的，去逛逛吧'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return CartItemCard(
                        item: item,
                        onToggle: () => ref
                            .read(cartDataProvider.notifier)
                            .toggleSelect(item.id),
                        onDelete: () => ref
                            .read(cartDataProvider.notifier)
                            .removeItem(item.id),
                        onQuantityChanged: (q) => ref
                            .read(cartDataProvider.notifier)
                            .updateQuantity(item.id, q),
                      );
                    },
                  ),
          ),
          // 底部结算栏
          SliverToBoxAdapter(child: const CartBottomBar()),
        ],
      ),
    );
  }

  void _showManageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除商品'),
        content: const Text('确定要清空购物车吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartDataProvider.notifier).clearAll();
              Navigator.pop(ctx);
            },
            child: const Text('清空', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
