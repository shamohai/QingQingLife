import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/points_mall_paging_providers.dart';
import 'points_product_card.dart';

/// 积分余额 + 热门兑换商品 统一白色卡片（顶部覆盖 Banner 底部）
class PointsBalanceCard extends ConsumerStatefulWidget {
  final int currentPoints;
  final int expiringPoints;
  final DateTime expiryDate;
  final VoidCallback? onDetailTap;

  const PointsBalanceCard({
    super.key,
    required this.currentPoints,
    required this.expiringPoints,
    required this.expiryDate,
    this.onDetailTap,
  });

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
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 到期提示条 ──
          if (widget.expiringPoints > 0) ...[
            Row(
              children: [
                const Icon(Icons.notification_important, size: 14, color: Color(0xFFFF2105)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '您有${widget.expiringPoints}积分将于${widget.expiryDate.year}年${widget.expiryDate.month}月${widget.expiryDate.day}日到期',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          // ── 积分余额行 ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                NumberFormat('#,##0').format(widget.currentPoints),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF090909),
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '积分余额',
                style: const TextStyle(fontSize: 9, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, size: 14, color: AppColors.outline),
              const Spacer(),
              GestureDetector(
                onTap: widget.onDetailTap,
                child: const Text(
                  '积分明细',
                  style: TextStyle(fontSize: 11, color: Color(0xFF0088FF), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE1E4DC)),
          // ── 热门兑换商品标题栏 ──
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              children: [
                const Text('热门兑换商品', style: TextStyle(fontSize: 12, color: Color(0xFF000000), fontWeight: FontWeight.w500)),
                const Spacer(),
                const Text('查看全部>>>', style: TextStyle(fontSize: 9, color: Color(0xFF8E8E93))),
              ],
            ),
          ),
          // ── 热门商品横向滚动列表 ──
          SizedBox(
            height: 110,
            child: HotProductsListView(controller: _scrollController),
          ),
        ],
      ),
    );
  }
}

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
        return ListView.builder(
          controller: controller,
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(right: 16),
          itemCount: items.length,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : 8),
            child: SizedBox(
              width: 74,
              child: PointsProductCard(product: items[index], compact: true),
            ),
          ),
        );
      },
    );
  }
}
