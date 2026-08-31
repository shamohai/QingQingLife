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
import '../../../../core/widgets/app_image.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartDataProvider);

    return Scaffold(
      bottomNavigationBar: state.items.isEmpty ? null : const CartBottomBar(),
      body: CustomScrollView(
        slivers: [
          _buildTopbar(state, context, ref),
          if (state.couponCode != null) _buildCouponBanner(state),
          // 商品列表
          if (state.items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: AppEmpty(message: '购物车是空的，去逛逛吧')),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext ctx, int index) {
                  final item = state.items[index];
                  return CartItemCard(
                    item: item,
                    onToggle: () => ref.read(cartDataProvider.notifier).toggleSelect(item.id),
                    onQuantityChanged: (q) => ref.read(cartDataProvider.notifier).updateQuantity(item.id, q),
                  );
                },
                childCount: state.items.length,
              ),
            ),
          const SliverToBoxAdapter(child: Divider(height: 1, thickness: 1)),
          _buildRecommendationsHeader(),
          _buildRecommendationsGrid(),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildTopbar(CartState state, BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: SafeArea(
        child: Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              Text('购物车', style: AppTextStyles.headlineSmall),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.onSurface),
                  const SizedBox(width: 4),
                  Text('天佑德营销中心', style: AppTextStyles.labelMedium),
                ],
              ),
              const Spacer(),
              if (state.items.isNotEmpty)
                GestureDetector(
                  onTap: () => _showManageDialog(context, ref),
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

  SliverToBoxAdapter _buildCouponBanner(CartState state) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard, size: 18, color: Color(0xFFFF8F00)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '已使用优惠券：${state.couponCode}',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRecommendationsHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(
          '猜你喜欢',
          style: AppTextStyles.headlineSmall.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildRecommendationsGrid() {
    final mockUrls = const [
      'https://loremflickr.com/160/160?random=100',
      'https://loremflickr.com/160/160?random=101',
      'https://loremflickr.com/160/160?random=102',
      'https://loremflickr.com/160/160?random=103',
    ];
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.9,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _RecommendationCell(url: mockUrls[index]),
          childCount: mockUrls.length,
        ),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
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

class _RecommendationCell extends StatelessWidget {
  final String url;
  const _RecommendationCell({required this.url});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AppNetworkImage(url: url, width: double.infinity, height: 144, fit: BoxFit.cover),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('商品', style: AppTextStyles.bodySmall),
      ],
    );
  }
}
