import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../data/models/points_mall_home_data.dart';

/// "我能兑换" 分区 — 左侧积分区间标签 + 右侧商品列表（每行横排）
class RedeemableSection extends StatelessWidget {
  final List<PointsRedeemGroup> groups;

  const RedeemableSection({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text('我能兑换', style: AppTextStyles.headlineSmall),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...groups.map((group) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _RedeemGroupRow(group: group),
        )),
      ],
    );
  }
}

class _RedeemGroupRow extends StatelessWidget {
  final PointsRedeemGroup group;

  const _RedeemGroupRow({required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧区间标签，加宽
          SizedBox(
            width: 88,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Text(
                  group.rangeLabel,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // 右侧商品列表（横排卡片）
          Expanded(
            child: group.products.isEmpty
                ? Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Center(
                      child: Text('暂无商品', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: group.products.map((p) => _RedeemProductRow(product: p)).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 单行兑换商品卡片：左侧图片 + 右上名称 + 右下积分
class _RedeemProductRow extends StatelessWidget {
  final PointsProduct product;

  const _RedeemProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          // 左侧图片
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: AppNetworkImage(
              url: product.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 右上：商品名称
                Text(
                  product.name,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // 右下：兑换积分
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, size: 12, color: Color(0xFFFF8F00)),
                    const SizedBox(width: 2),
                    Text(
                      '${product.points}积分',
                      style: AppTextStyles.priceSmall.copyWith(color: const Color(0xFFFF8F00), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}