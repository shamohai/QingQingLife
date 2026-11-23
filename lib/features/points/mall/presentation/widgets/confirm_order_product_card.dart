import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../data/models/service_product_detail_model.dart';

/// 确认订单商品卡片
class ConfirmOrderProductCard extends StatefulWidget {
  final ServiceProductDetail product;
  final int quantity;
  final bool isQuantityEditable;
  final bool isQuantityValidating;

  /// 权益进入时无需支付积分，积分价格画删除线
  final bool isBenefit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onQuantityChanged;

  const ConfirmOrderProductCard({
    super.key,
    required this.product,
    required this.quantity,
    this.isQuantityEditable = true,
    this.isQuantityValidating = false,
    this.isBenefit = false,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQuantityChanged,
  });

  @override
  State<ConfirmOrderProductCard> createState() => _ConfirmOrderProductCardState();
}

class _ConfirmOrderProductCardState extends State<ConfirmOrderProductCard> {
  late TextEditingController _qtyController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '${widget.quantity}');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant ConfirmOrderProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isQuantityValidating && !widget.isQuantityValidating && oldWidget.quantity == widget.quantity) {
      _qtyController.text = '${widget.quantity}';
    }
    if (oldWidget.quantity != widget.quantity) {
      final newText = '${widget.quantity}';
      if (_qtyController.text != newText) {
        _qtyController.text = newText;
        if (_focusNode.hasFocus) {
          _qtyController.selection = TextSelection.collapsed(offset: newText.length);
        }
      }
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQuantitySubmitted(String value) {
    if (!widget.isQuantityEditable) return;
    final newQty = int.tryParse(value);
    if (newQty != null && newQty > 0) {
      widget.onQuantityChanged(newQty);
    } else {
      _qtyController.text = '${widget.quantity}';
      _qtyController.selection = TextSelection.collapsed(offset: _qtyController.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - AppSpacing.compactPageMargin * 2).clamp(0.0, 414.0);

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.compactPageMargin),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上半部分（商品信息）
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RepaintBoundary(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: AppNetworkImage(
                            url: widget.product.mainImageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            memCacheWidth: 140,
                            memCacheHeight: 140,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.product.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2024)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [Wrap(spacing: 6, runSpacing: 4, children: widget.product.tags.map((tag) => _TagPill(label: tag)).toList())],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.product.points}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF2105),
                            decoration: widget.isBenefit ? TextDecoration.lineThrough : TextDecoration.none,
                            decorationColor: const Color(0xFFFF2105),
                          ),
                        ),
                        Text(
                          '积分',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF2105),
                            decoration: widget.isBenefit ? TextDecoration.lineThrough : TextDecoration.none,
                            decorationColor: const Color(0xFFFF2105),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
                        children: [
                          const TextSpan(text: '市场价:'),
                          TextSpan(
                            text: '¥${widget.product.marketPrice.toStringAsFixed(2)}',
                            style: const TextStyle(decoration: TextDecoration.lineThrough, decorationColor: Color(0xFF8E8E97)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 下半部分
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 12),
            child: Column(
              children: [
                // 第一行：数量加减 + 可输入文本框（靠右）
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _QtyButton(label: '-', onTap: widget.isQuantityEditable ? widget.onDecrement : null, isMinus: true, enabled: widget.isQuantityEditable),
                    Container(
                      width: 36,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.isQuantityEditable ? Colors.white : const Color(0xFFF3F5F7),
                        border: const Border.symmetric(horizontal: BorderSide(color: Color(0xFFD9D9D9), width: 1.0)),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _qtyController,
                        focusNode: _focusNode,
                        enabled: widget.isQuantityEditable && !widget.isQuantityValidating,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: widget.isQuantityEditable ? const Color(0xFF1F2024) : const Color(0xFF8E8E97),
                          height: 1.2,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: widget.isQuantityEditable ? Colors.white : const Color(0xFFF3F5F7),
                          filled: true,
                        ),
                        onSubmitted: _onQuantitySubmitted,
                        onEditingComplete: () {
                          _onQuantitySubmitted(_qtyController.text);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    _QtyButton(label: '+', onTap: widget.isQuantityEditable ? widget.onIncrement : null, isMinus: false, enabled: widget.isQuantityEditable),
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

class _QtyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isMinus;
  final bool enabled;

  const _QtyButton({required this.label, required this.onTap, this.isMinus = false, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final borderRadius = isMinus
        ? const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))
        : const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8));

    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 18,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF3F5F7) : const Color(0xFFEBEBEB),
          border: Border.all(color: const Color(0xFFD9D9D9)),
          borderRadius: borderRadius,
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: enabled ? const Color(0xFF000000) : const Color(0xFFA0A0A0), height: 1.0),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;

  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      height: 17,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF2105)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Color(0xFFFF2105)),
        ),
      ),
    );
  }
}
