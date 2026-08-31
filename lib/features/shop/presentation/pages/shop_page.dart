import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/shop_service_tier_provider.dart';
import '../widgets/service_tier_card.dart';
import '../widgets/shop_product_list_item.dart';
import '../widgets/shop_sub_category_tab.dart';
import '../../domain/models/service_tier.dart';

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategory = ref.watch(activeCategoryProvider);
    final categories = ref.watch(serviceCategoriesProvider);
    final activeCat = ref.watch(shopListDataProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('特色商城'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildKingKongNav(ref, activeCategory, categories),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: activeCat.isProductList
                ? _buildProductListLayout(ref, activeCat)
                : _buildServiceTierLayout(ref, activeCat),
          ),
        ],
      ),
    );
  }

  // ─── 服务档位布局（购酒享服务 / 青藏特色 / 丁香香油） ─────────────

  Widget _buildServiceTierLayout(WidgetRef ref, ServiceCategory cat) {
    final tiers = cat.serviceTiers ?? [];
    return tiers.isEmpty
        ? const Center(child: Text('暂无服务', style: AppTextStyles.bodyMedium))
        : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: tiers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 0),
            itemBuilder: (context, index) => ServiceTierCard(tier: tiers[index]),
          );
  }

  // ─── 商品列表布局（电商特供：左侧子分类 + 右侧商品流） ──────────

  Widget _buildProductListLayout(WidgetRef ref, ServiceCategory cat) {
    final subCats = cat.subCategories ?? [];
    final products = cat.products ?? [];
    return Row(
      children: [
        // 左侧子分类边栏
        if (subCats.isNotEmpty)
          Container(
            width: 72,
            color: const Color(0xFFE8E8E8),
            child: ListView.builder(
              itemCount: subCats.length,
              itemBuilder: (context, index) {
                final sub = subCats[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ShopSubCategoryTab(
                    label: sub.label,
                    isSelected: index == 0,
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        // 右侧商品内容区
        Expanded(
          child: CustomScrollView(
            slivers: [
              // 活动 Banner 占位
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, bottom: AppSpacing.sm),
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Center(
                    child: Text(
                      '活动banner图\n可轮播，可配置专题页',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall,
                    ),
                  ),
                ),
              ),
              // 商品列表
              if (products.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(child: Text('暂无商品', style: AppTextStyles.bodyMedium)),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ShopProductListItem(product: products[index]),
                      childCount: products.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            ],
          ),
        ),
      ],
    );
  }

  // ─── 搜索栏 ───────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: '搜索心仪好物',
                  hintStyle: AppTextStyles.bodySmall,
                  prefixIcon: Icon(Icons.search, size: 18, color: AppColors.outline),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
            child: const Center(
              child: Text(
                '搜索',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 金刚区导航 ───────────────────────────────────────────────────

  Widget _buildKingKongNav(
    WidgetRef ref,
    String activeId,
    List<ServiceCategory> categories,
  ) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = cat.id == activeId;
          return GestureDetector(
            onTap: () => ref.read(activeCategoryProvider.notifier).setActive(cat.id),
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      cat.icon,
                      size: 26,
                      color: isActive ? AppColors.primary : AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
