import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/widgets/app_empty.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../providers/points_mall_providers.dart';
import 'points_hot_product_card.dart';

/// 积分余额 + 热门兑换商品 统一白色卡片（顶部覆盖 Banner 底部）
class PointsBalanceCard extends ConsumerStatefulWidget {
  final int currentPoints;
  final int expiringPoints;
  final VoidCallback? onDetailTap;

  const PointsBalanceCard({super.key, required this.currentPoints, required this.expiringPoints, this.onDetailTap});

  @override
  ConsumerState<PointsBalanceCard> createState() => _PointsBalanceCardState();
}

class _PointsBalanceCardState extends ConsumerState<PointsBalanceCard> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5), // 与 home_page.dart 保持一致（上下边距 5dp）
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 4), // 底部收紧，减少热门兑换下方留白
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 到期提示条（蓝色图标 + 蓝色高亮积分数字）──
          if (widget.expiringPoints > 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8), // 专属的左右间距
              child: Row(
                children: [
                  Image.asset('assets/images/points/icon-notification.png', width: 16, height: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: '您有',
                        children: [
                          TextSpan(
                            text: '${widget.expiringPoints}积分',
                            style: const TextStyle(color: Color(0xFF0088FF)),
                          ),
                          const TextSpan(text: '即将到期，请尽快使用'),
                        ],
                      ),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
          // ── 积分余额行 ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8), // 专属的左右间距
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          NumberFormat('#,###').format(widget.currentPoints),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF090909), height: 1.1, letterSpacing: -0.5),
                        ),
                        const SizedBox(width: 2),
                        Transform.translate(
                          offset: const Offset(0, -2),
                          child: const Icon(Icons.info_outline, size: 14, color: AppColors.outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '积分余额',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF8E8E93)),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onDetailTap,
                  child: Container(
                    width: 70,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF0088FF), width: 1),
                      borderRadius: BorderRadius.circular(67),
                    ),
                    child: const Text(
                      '积分明细',
                      style: TextStyle(fontSize: 12, color: Color(0xFF0088FF), fontWeight: FontWeight.w500, height: 1.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // const Divider(height: 1, thickness: 0.5, color: Color(0xFFE1E4DC)),
          // ── 热门兑换商品标题栏（蓝色图标）──
          Container(
            margin: const EdgeInsets.only(top: 0),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              height: 36,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/points/icon-hot-products.png', width: 20, height: 20),
                  const SizedBox(width: 4),
                  const Text(
                    '热门兑换商品',
                    style: TextStyle(fontSize: 15, color: Color(0xFF000000), fontWeight: FontWeight.w600, height: 1.0),
                  ),
                  const Spacer(),
                  // GestureDetector(
                  //   onTap: () => GoRouter.of(context).push('/points/all-products'),
                  //   child: const Text('查看全部>>>', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93), height: 1.0)),
                  // ),
                ],
              ),
            ),
          ),
          // ── 热门商品横向滚动列表（高度 = 卡片真实渲染高度，运行时测量）──
          HotProductsListView(controller: _scrollController),
        ],
      ),
    );
  }
}

/// 热门商品横向列表：SingleChildScrollView(横向) + Row，高度由卡片真实布局决定，
/// 不写死高度，也不做运行时测量，避免字体缩放与平台差异导致的溢出或留白。
class HotProductsListView extends ConsumerWidget {
  final ScrollController controller;

  const HotProductsListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsData = ref.watch(pointsMallHotProductsProvider);

    return productsData.when(
      loading: () => const Center(child: AppLoading()),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const AppEmpty(message: '暂无热门商品');
        return SingleChildScrollView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                PointsHotProductCard(
                  product: items[i],
                  onTap: () {
                    GoRouter.of(context).push('/points/service/${items[i].id}');
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
