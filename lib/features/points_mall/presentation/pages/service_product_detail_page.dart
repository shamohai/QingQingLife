import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/app_loading.dart';
import '../../../../../core/widgets/app_error.dart';
import '../providers/service_product_detail_provider.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/product_info_card.dart';
import '../widgets/product_visual_card.dart';
import '../../data/models/service_product_detail_model.dart';

/// 积分商城服务商品详情页
///
/// 来自蓝湖设计稿：/points/service/:id
class ServiceProductDetailPage extends ConsumerWidget {
  final String productId;

  const ServiceProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(serviceProductDetailProvider(productId));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: Stack(
        children: [
          // ── 滚动内容层 ──
          productAsync.when(
            loading: () => const Center(child: AppLoading()),
            error: (error, stack) => Center(
              child: AppError(
                message: '加载失败: $error',
                onRetry: () => ref.invalidate(serviceProductDetailProvider(productId)),
              ),
            ),
            data: (product) => _buildContent(context, ref, product),
          ),

          // ── 固定底栏（数据加载完成后才显示）──
          // 使用 Consumer 确保数据就绪后追加底栏
          // （此处用 builder 方式在 when data 中内嵌）
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ServiceProductDetail product) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Hero Section
            SliverToBoxAdapter(
              child: HeroSection(
                product: product,
                onBack: () => context.pop(),
              ),
            ),

            // ProductInfoCard（负 margin 与 Hero 叠加）
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: -36, left: 14, right: 14, bottom: 12),
                child: ProductInfoCard(product: product),
              ),
            ),

            // ProductVisualCard
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                child: ProductVisualCard(product: product),
              ),
            ),

            // 底部留白，避免被固定底栏遮挡
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),

        // 固定底栏
        Positioned.fill(
          bottom: 0,
          child: BottomActionBar(
            onExchange: () => _handleExchange(context, product),
          ),
        ),
      ],
    );
  }

  void _handleExchange(BuildContext context, ServiceProductDetail product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('兑换商品：${product.title}')),
    );
  }
}
