import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../providers/all_orders_provider.dart';
import '../../domain/enums/order_type.dart';

/// 订单卡片（通用，支持商城/积分/服务三种类型）
class OrderCard extends StatelessWidget {
  final OrderCardItem item;

  const OrderCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${item.id}'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(),
              const SizedBox(height: AppSpacing.sm),
              _buildProductRow(),
              const SizedBox(height: AppSpacing.sm),
              _buildStatusBadgeRow(),
              const SizedBox(height: AppSpacing.xs),
              _buildMetaRow(),
              const SizedBox(height: AppSpacing.sm),
              _buildActionButtonsRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${item.orderPrefix} ${item.orderNo}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF213775)),
        ),
        Text(
          item.statusText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFFF2105)),
        ),
      ],
    );
  }

  Widget _buildProductRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: AppNetworkImage(
            url: item.items.isNotEmpty ? item.items.first.imageUrl : 'assets/images/product/product1.jpg',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: SizedBox(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (item.items.isNotEmpty) ...[
                  Text(
                    item.items.first.productName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface, height: 1.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.items.first.skuName,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97), height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  const Text(
                    '天佑德电商专供青稞酒...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface, height: 1.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  _buildSpecTags(),
                  const SizedBox(height: 5),
                  const Text(
                    '【规格一】天佑德电商专供青稞酒特别版本42度500ml',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97), height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildPriceColumn(),
      ],
    );
  }

  Widget _buildSpecTags() {
    return Row(children: [_specTag('清香型'), SizedBox(width: 4), _specTag('52%vol')]);
  }

  Widget _specTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF2105), width: 0.8),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Color(0xFFFF2105)),
      ),
    );
  }

  Widget _buildPriceColumn() {
    final qty = item.items.isNotEmpty ? item.items.first.quantity : 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (item.orderType == OrderType.points && item.pointsCost != null)
          Text(
            '${item.pointsCost}积分',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          )
        else
          _priceDisplay(item.totalAmountCents),
        const SizedBox(height: 6),
        Text(
          '×$qty',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
        ),
      ],
    );
  }

  Widget _priceDisplay(int cents) {
    final yuan = cents / 100;
    final yuanInt = yuan.toInt();
    final yuanStr = yuanInt.toString();
    final decimal = (yuan - yuanInt).toStringAsFixed(2).substring(1);
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurface),
        children: [
          TextSpan(text: '¥', style: const TextStyle(fontSize: 12)),
          TextSpan(text: yuanStr, style: const TextStyle(fontSize: 20)),
          TextSpan(text: decimal, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatusBadgeRow() {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(color: const Color(0xFFF3F5F7), borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Row(
        children: [
          const SizedBox(width: 23),
          Text(
            item.mainStatusDesc,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.subStatusDesc,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.chevron_right, color: Color(0xFF8E8E97)),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    final timeLabel = item.orderType == OrderType.points ? '兑换时间' : '下单时间';
    final timeStr =
        '${item.createTime.year}-${item.createTime.month.toString().padLeft(2, '0')}-${item.createTime.day.toString().padLeft(2, '0')}  ${item.createTime.hour.toString().padLeft(2, '0')}:${item.createTime.minute.toString().padLeft(2, '0')}:${item.createTime.second.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Text(
          '$timeLabel:$timeStr',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
        ),
        const Spacer(),
        const Text(
          '总计:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface),
        ),
        const SizedBox(width: 8),
        if (item.orderType == OrderType.points && item.pointsCost != null)
          Text(
            '${item.pointsCost}积分',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          )
        else
          _metaPrice(item.totalAmountCents),
      ],
    );
  }

  Widget _metaPrice(int cents) {
    final yuan = cents / 100;
    final yuanInt = yuan.toInt();
    final yuanStr = yuanInt.toString();
    final decimal = (yuan - yuanInt).toStringAsFixed(2).substring(1);
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurface),
        children: [
          TextSpan(text: '¥', style: const TextStyle(fontSize: 12)),
          TextSpan(text: yuanStr, style: const TextStyle(fontSize: 20)),
          TextSpan(text: decimal, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    if (item.actions.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: item.actions.map((action) => _buildButton(context, action)).toList(),
    );
  }

  /// 按钮：primary 用渐变蓝背景，secondary 用灰色 outline 风格
  Widget _buildButton(BuildContext context, OrderActionButton action) {
    return GestureDetector(
      onTap: action.onTap ?? () => context.push('/orders/${item.id}'),
      child: Container(
        margin: const EdgeInsets.only(left: AppSpacing.md),
        height: 44,
        width: 96,
        decoration: action.isPrimary
            ? BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3152AF), Color(0xFF213775)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(999),
              )
            : BoxDecoration(color: const Color(0xFFF3F5F7), borderRadius: BorderRadius.circular(999)),
        child: Center(
          child: Text(
            action.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: action.isPrimary ? FontWeight.w500 : FontWeight.w400,
              color: action.isPrimary ? Colors.white : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
