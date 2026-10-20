import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/entities/order_list_order.dart';

class OrderCard extends StatelessWidget {
  final OrderListOrder item;

  const OrderCard({super.key, required this.item});

  void _showPending(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$action接口暂未接入')));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPending(context, '订单详情'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(),
              const SizedBox(height: AppSpacing.sm),
              for (final product in item.products.isEmpty ? const [OrderListProduct()] : item.products)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildProductRow(product),
                ),
              _buildStatusBadgeRow(),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(height: 30, child: _buildMetaRow()),
              if (item.actions.isNotEmpty) ...[const SizedBox(height: AppSpacing.sm), _buildActionButtonsRow(context)],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '${_orderPrefix(item.typeCode)}${item.orderNo ?? '—'}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF213775)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          item.statusLabel,
          textAlign: TextAlign.end,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFFF2105)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ],
    );
  }

  Widget _buildProductRow(OrderListProduct product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: SizedBox(
            width: 100,
            height: 100,
            child: product.image == null
                ? const ColoredBox(
                    color: Color(0xFFF3F5F7),
                    child: Center(child: Icon(Icons.broken_image_outlined, size: 48, color: AppColors.onSurfaceVariant)),
                  )
                : AppNetworkImage(url: product.image!, width: 100, height: 100, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name ?? '商品名称',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface, height: 1.3),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              _buildSpecTags(product),
              if (product.priceDescription?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 5),
                Text(
                  product.priceDescription!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97), height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildProductPrice(product),
              const SizedBox(height: 6),
              Text('×${product.quantity ?? 'j'}', style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E97))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _specTag(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFFF2105), width: 0.8),
      borderRadius: BorderRadius.circular(AppRadius.xs),
    ),
    child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFFFF2105))),
  );

  Widget _buildStatusBadgeRow() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF3F5F7), borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Row(
        children: [
          Expanded(
            child: Text(item.statusLabel, style: const TextStyle(fontSize: 14, color: AppColors.onSurface)),
          ),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF8E8E97)),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    final createdAt = item.createdAt;
    final time = createdAt == null
        ? 'l'
        : '${createdAt.year}-${_pad(createdAt.month)}-${_pad(createdAt.day)}  ${_pad(createdAt.hour)}:${_pad(createdAt.minute)}:${_pad(createdAt.second)}';
    final isCreditOrder = const [2, 7, 25].contains(item.typeCode);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            isCreditOrder ? '兑换时间: m' : '下单时间: $time',
            style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E97)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        _buildTotalPrice(),
      ],
    );
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');

  static String _orderPrefix(int? typeCode) {
    if (const [2, 7, 25].contains(typeCode)) return '积分订单编号：';
    if (typeCode == 9 || typeCode == 23) return '服务订单编号：';
    return '商城订单编号：';
  }

  Widget _buildSpecTags(OrderListProduct product) {
    final parameters = <String, String>{for (final parameter in product.parameters) parameter.name.trim(): parameter.value.trim()};
    final degree = parameters['度数'];
    final flavor = parameters['香型'];
    final tags = <String>[if (degree != null && degree.isNotEmpty) _degreeLabel(degree), if (flavor != null && flavor.isNotEmpty) flavor];
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 6, children: tags.map(_specTag).toList());
  }

  static String _degreeLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('°') || trimmed.endsWith('度')) {
      return '${trimmed.substring(0, trimmed.length - 1)}%vol';
    }
    return trimmed;
  }

  Widget _buildProductPrice(OrderListProduct product) {
    final payAmountDescription = product.payAmountDescription;
    if (payAmountDescription != null) {
      return _amountDescriptionText(payAmountDescription, mainFontSize: 16);
    }
    if (item.isCreditOrder == true) {
      return Text(
        '${product.creditPrice ?? '—'}积分',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      );
    }
    if (product.priceCents == null) {
      return const Text('—', style: TextStyle(fontSize: 16, color: AppColors.onSurface));
    }
    final absolute = product.priceCents!.abs();
    return Text(
      '${product.priceCents! < 0 ? '-' : ''}¥${absolute ~/ 100}.${_pad(absolute % 100)}',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    );
  }

  Widget _amountDescriptionText(String value, {required double mainFontSize}) {
    final match = RegExp(r'^([^\d]*)(\d+)(\.\d+)?(.*)$').firstMatch(value.trim());
    if (match == null) {
      return Text(
        value,
        style: TextStyle(fontSize: mainFontSize, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      );
    }

    final prefix = match.group(1) ?? '';
    final integer = match.group(2) ?? '';
    final decimal = match.group(3) ?? '';
    final suffix = match.group(4) ?? '';
    const smallStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface);
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppColors.onSurface),
        children: [
          if (prefix.isNotEmpty) TextSpan(text: prefix, style: smallStyle),
          TextSpan(
            text: integer,
            style: TextStyle(fontSize: mainFontSize, fontWeight: FontWeight.w600),
          ),
          if (decimal.isNotEmpty) TextSpan(text: decimal, style: smallStyle),
          if (suffix.isNotEmpty) TextSpan(text: suffix, style: smallStyle),
        ],
      ),
    );
  }

  Widget _buildTotalPrice() {
    final payAmountDescription = item.payAmountDescription ?? (item.products.isNotEmpty ? item.products.first.payAmountDescription : null);
    if (payAmountDescription != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Text('总计: ', style: TextStyle(fontSize: 16, color: AppColors.onSurface)),
          _amountDescriptionText(payAmountDescription, mainFontSize: 20),
        ],
      );
    }
    if (item.isCreditOrder == true) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.onSurface),
          children: [
            const TextSpan(text: '总计: ', style: TextStyle(fontSize: 16)),
            TextSpan(
              text: '${item.consumedPoints ?? '—'}积分',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const Text('总计: ', style: TextStyle(fontSize: 16, color: AppColors.onSurface)),
        _moneyText(item.amountCents, mainFontSize: 20),
      ],
    );
  }

  Widget _moneyText(int? cents, {required double mainFontSize}) {
    if (cents == null) return const Text('—', style: TextStyle(fontSize: 16, color: AppColors.onSurface));
    final absolute = cents.abs();
    final prefix = cents < 0 ? '-¥' : '¥';
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppColors.onSurface),
        children: [
          TextSpan(
            text: prefix,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: '${absolute ~/ 100}',
            style: TextStyle(fontSize: mainFontSize, fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: '.${_pad(absolute % 100)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        alignment: WrapAlignment.end,
        children: item.actions.map((action) => _buildButton(context, action)).toList(),
      ),
    );
  }

  Widget _buildButton(BuildContext context, OrderListAction action) {
    return GestureDetector(
      onTap: () => _showPending(context, action.label),
      child: Container(
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
