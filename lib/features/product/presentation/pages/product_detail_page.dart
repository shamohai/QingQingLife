import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/product_detail_provider.dart';
import '../widgets/product_detail_widgets.dart';

class ProductDetailPage extends ConsumerWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(productDetailProvider(productId));
    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: detail.asData?.value == null
          ? AppBar(
              title: const Text('商品详情'),
              leading: BackButton(onPressed: () => _back(context)),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: detail.when(
          loading: () => const AppLoading(),
          error: (error, stack) => AppError(onRetry: () => ref.invalidate(productDetailProvider(productId))),
          data: (data) => data == null
              ? const AppEmpty(message: '暂无商品详情')
              : RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productDetailProvider(productId));
                    await ref.read(productDetailProvider(productId).future);
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: ProductHero(key: const ValueKey('product-hero'), images: data.product.images, onBack: () => _back(context)),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        sliver: SliverList.list(
                          children: [
                            PriceBenefits(key: const ValueKey('product-price-benefits'), detail: data, onCoupon: () => _message(context, '优惠券领取')),
                            const SizedBox(height: 10),
                            ReviewsSection(key: const ValueKey('product-reviews'), detail: data, onViewAll: () => _message(context, '查看全部评价')),
                            const SizedBox(height: 10),
                            DetailSection(key: const ValueKey('product-description'), image: data.detailImage),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: detail.asData?.value == null
          ? null
          : PurchaseBar(
              key: const ValueKey('product-purchase-bar'),
              onHome: () => context.go(RouteNames.home),
              onService: () => _message(context, '联系客服'),
              onCart: () => context.push(RouteNames.cart),
              onAdd: () => context.push(RouteNames.cart),
              onBuy: () => context.push(RouteNames.mallConfirmOrder),
            ),
    );
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  void _message(BuildContext context, String action) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('当前为本地预览，$action功能待接入')));
}
