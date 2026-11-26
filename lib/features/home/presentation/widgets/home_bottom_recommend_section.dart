import 'dart:math' as math;

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../points/mall/data/models/get_credit_product_list_model.dart';
import '../providers/home_paging_providers.dart';

/// 首页底部推荐展示区（模块 1 元宝卡片 + 动态青稞粒商品错落列表 + 底部 bottom.png）
class HomeBottomRecommendSection extends ConsumerWidget {
  const HomeBottomRecommendSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagingData = ref.watch(homeRecommendCreditProductsProvider);

    if (pagingData.status == PagingStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(homeRecommendCreditProductsProvider.notifier).loadFirstPage();
      });
    }

    final items = pagingData.items;

    // 分离左右两列元素
    final leftCards = <Widget>[];
    final rightCards = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final card = _ProductCard(product: items[i]);
      if (i % 2 == 0) {
        leftCards.add(card);
      } else {
        rightCards.add(card);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧列：偶数索引商品
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < leftCards.length; i++) ...[if (i > 0) const SizedBox(height: 12), leftCards[i]],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.compactItemGap),
            // 右侧列：奇数索引商品
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < rightCards.length; i++) ...[if (i > 0) const SizedBox(height: 12), rightCards[i]],
                ],
              ),
            ),
          ],
        ),

        // 底部加载状态指示
        if (pagingData.isLoading) ...[
          const SizedBox(height: 20),
          const Center(
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
          ),
        ],

        // 错误重试指示
        if (pagingData.isError && items.isEmpty) ...[
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: () => ref.read(homeRecommendCreditProductsProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
              label: const Text('加载失败，点击重试', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],

        const SizedBox(height: 30),

        // 底部居中的 bottom.png (67x20) 及下箭头，整体水平居中
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/home/bottom.png',
                width: 67,
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 4),
              if (!pagingData.hasMore && items.isNotEmpty)
                const Text('没有更多了', style: TextStyle(fontSize: 10, color: Colors.white70))
              else
                const SizedBox(width: 24, height: 14, child: Icon(Icons.keyboard_arrow_down, size: 24, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final CreditProductItem product;

  const _ProductCard({required this.product});

  /// 无货判定：warning 字段包含“无货”即视为暂时无货（与小程序一致）
  bool get _isOutOfStock => product.warning?.contains('无货') ?? false;

  @override
  Widget build(BuildContext context) {
    final outOfStock = _isOutOfStock;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(8),
      child: InkWell(
        // 无货商品不可点击跳转
        onTap: outOfStock
            ? null
            : () {
                // 点击跳转积分商品详情页
                context.push(RouteNames.serviceProductDetail.replaceFirst(':id', '${product.productId}'));
              },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 商品图片，圆角 4dp；无货时叠加灰色蒙层与斜向“暂时缺货”印章
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  AppNetworkImage(
                    url: product.imgUrl,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      height: 140,
                      color: const Color(0xFFF5F5F5),
                      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                    ),
                  ),
                  if (outOfStock) ...[Positioned.fill(child: ColoredBox(color: const Color(0x80000000))), const Positioned.fill(child: _OutOfStockStamp())],
                ],
              ),
            ),
            const SizedBox(height: 6),
            // 名称行
            Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: const EdgeInsets.only(right: 4, bottom: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF213775), // 同 Home 藏青色背景 #213775
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        product.isCredit ? '积分专享' : '会员价',
                        style: const TextStyle(
                          color: Color(0xFFD7B480), // 金色文字
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  TextSpan(
                    text: product.productName,
                    style: const TextStyle(color: Color(0xFF000000), fontSize: 11, height: 1.25),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            // 积分/价格与购物车行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${product.creditPrice}',
                        style: const TextStyle(color: Color(0xFFFF2105), fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        '积分',
                        style: TextStyle(color: Color(0xFFFF2105), fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/home/cart_red.png',
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_cart, size: 16, color: Color(0xFFFF2105)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 无货印章（分步调整中）：双环保持不变；水平文字条左右贴边，高度占蒙层 1/4，内部为“暂时缺货”
class _OutOfStockStamp extends StatelessWidget {
  const _OutOfStockStamp();

  static const _stampSize = 104.0;
  static const _outerRadius = _stampSize / 2; // 外环半径 52
  static const _innerRadius = 30.0; // 内环半径
  static const _starRadius = (_outerRadius + _innerRadius) / 2; // 星标位于两环正中
  static const _starCount = 12;
  static const _strokeColor = Color(0xD9FFFFFF);
  static const _barHeightFactor = 0.25; // 文字长方形高度占蒙层 1/4
  static const _barAngle = math.pi / 12; // 顺时针 15°

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 双环 + 星标（保持不变）
        Center(
          child: SizedBox(
            width: _stampSize,
            height: _stampSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _strokeColor, width: 2),
                  ),
                ),
                Container(
                  width: _innerRadius * 2,
                  height: _innerRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _strokeColor, width: 2),
                  ),
                ),
                for (int i = 0; i < _starCount; i++)
                  Transform.translate(
                    offset: Offset(
                      math.cos(2 * math.pi * i / _starCount - math.pi / 2) * _starRadius,
                      math.sin(2 * math.pi * i / _starCount - math.pi / 2) * _starRadius,
                    ),
                    child: const Icon(Icons.star, size: 6, color: _strokeColor),
                  ),
              ],
            ),
          ),
        ),
        // 文字长方形（框 + 文字整体）：顺时针 15°，左下角贴蒙层左边，右上角贴蒙层右边
        LayoutBuilder(
          builder: (context, constraints) {
            final maskWidth = constraints.maxWidth;
            final barHeight = constraints.maxHeight * _barHeightFactor; // 高度占蒙层 1/4
            const angle = _barAngle;
            // 旋转后左下角到右上角的水平距离 = w·cosθ + h·sinθ，令其等于蒙层宽度
            final barWidth = (maskWidth - barHeight * math.sin(angle)) / math.cos(angle);
            return Center(
              child: Transform.rotate(
                angle: angle,
                child: Container(
                  width: barWidth,
                  height: barHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xE6FFFFFF), width: 2)),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(
                      '暂时缺货',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                        height: 1.1,
                        shadows: [Shadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1))],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
