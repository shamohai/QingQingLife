import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/route_names.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../../../../../core/widgets/app_error.dart';
import '../../../../../core/widgets/app_share_sheet.dart';
import '../providers/service_product_detail_provider.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/hero_section.dart';
import '../../../../../app/theme/app_spacing.dart';
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
      backgroundColor: const Color(0xFF213775),
      body: Stack(
        children: [
          // ── 滚动内容层 ──
          productAsync.when(
            loading: () => const Center(child: AppLoading()),
            error: (error, stack) => Center(
              child: AppError(message: '加载失败: $error', onRetry: () => ref.invalidate(serviceProductDetailProvider(productId))),
            ),
            data: (product) => _buildContent(context, ref, product),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ServiceProductDetail product) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Stack(
      children: [
        CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: HeroSection(
                product: product,
                onBack: () => context.pop(),
                onShare: () => AppShareSheet.showAppPage(
                  context: context,
                  title: product.title,
                  description: product.description,
                  location: RouteNames.serviceProductDetailPath(productId: productId),
                  imageUrl: product.mainImageUrl.isEmpty ? null : product.mainImageUrl,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.compactPageMargin, vertical: 12),
                child: ProductInfoCard(product: product),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.compactPageMargin, right: AppSpacing.compactPageMargin, top: 6, bottom: 6),
                child: ProductVisualCard(product: product),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 85 + bottomInset)),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: BottomActionBar(product: product, productId: productId),
          ),
        ),
      ],
    );
  }
}
