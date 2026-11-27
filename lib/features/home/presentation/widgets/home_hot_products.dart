import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../../points/mall/data/models/get_recommend_product_list_model.dart';
import '../providers/home_paging_providers.dart';
import 'home_credit_product_card.dart';

/// 热卖商品横向滚动列表（白色卡片容器）
/// 设计稿：白色卡片，"热卖商品" 标题 + "查看全部"，横向滚动 112x112 图片
class HomeHotProducts extends ConsumerWidget {
  const HomeHotProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5, // 上下边距
        horizontal: 12, // 左右边距
      ),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(AppRadius.md))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/home/kingkong_member.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                      child: const Icon(Icons.local_fire_department, size: 10, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('热门兑换', style: AppTextStyles.headlineSmall),
                ],
              ),
              // GestureDetector(
              //   onTap: () {
              //     final pagingData = ref.read(homeHotProductsProvider);
              //     if (!pagingData.isLoading && pagingData.hasMore) {
              //       ref.read(homeHotProductsProvider.notifier).loadMore();
              //     }
              //   },
              //   child: const Text(
              //     '查看全部>>>',
              //     style: TextStyle(
              //       color: Color(0xFF8E8E93), // #ff8e8e93 文字颜色
              //       fontSize: 9, // 9sp 文字大小
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Consumer(
            builder: (context, ref, child) {
              final pagingData = ref.watch(homeHotProductsProvider);
              if (pagingData.status == PagingStatus.initial) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    ref.read(homeHotProductsProvider.notifier).loadFirstPage();
                  }
                });
              }

              if (pagingData.isLoading && pagingData.items.isEmpty) {
                return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
              }
              if (pagingData.isError && pagingData.items.isEmpty) {
                return SizedBox(height: 60, child: Center(child: Text(pagingData.errorMessage ?? '加载失败')));
              }
              if (pagingData.items.isEmpty) {
                return const SizedBox(height: 60, child: Center(child: Text('暂无数据')));
              }

              return HotProductsStrip(items: pagingData.items);
            },
          ),
        ],
      ),
    );
  }
}

/// 横向商品列表。
///
/// 列表高度不写死：布局完成后读取一张真实卡片的渲染高度（运行时测量），
/// 因此高度始终与当前字体缩放下的卡片实际高度一致，既不溢出也不留白。
class HotProductsStrip extends StatefulWidget {
  final List<CreditMallProduct> items;

  const HotProductsStrip({super.key, required this.items});

  @override
  State<HotProductsStrip> createState() => HotProductsStripState();
}

class HotProductsStripState extends State<HotProductsStrip> {
  final _measureKey = GlobalKey();
  double? _height;

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _measureKey.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) return;
      final h = box.size.height;
      if (h != _height) {
        setState(() => _height = h);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 依赖字体缩放：字体变化时重建并重新测量高度
    MediaQuery.textScalerOf(context);
    _scheduleMeasure();
    final height = _height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 测量用：Offstage 仍会布局但不绘制、不占空间、不响应点击
        Offstage(
          child: HomeCreditProductCard(key: _measureKey, product: widget.items.first),
        ),
        if (height != null)
          SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: widget.items.length,
              separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final product = widget.items[index];
                return GestureDetector(
                  onTap: () => context.push(RouteNames.serviceProductDetail.replaceFirst(':id', '${product.productId}')),
                  child: HomeCreditProductCard(product: product),
                );
              },
            ),
          ),
      ],
    );
  }
}
