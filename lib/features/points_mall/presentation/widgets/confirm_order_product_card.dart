import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/widgets/app_image.dart';
import '../../data/models/service_product_detail_model.dart';

/// 确认订单商品卡片
class ConfirmOrderProductCard extends StatefulWidget {
  final ServiceProductDetail product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onQuantityChanged;

  const ConfirmOrderProductCard({
    super.key,
    required this.product,
    required this.quantity,
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
    final newQty = int.tryParse(value);
    if (newQty != null && newQty > 0) {
      widget.onQuantityChanged(newQty);
    } else {
      // 输入非法时恢复成当前正确数量
      _qtyController.text = '${widget.quantity}';
      _qtyController.selection = TextSelection.collapsed(offset: _qtyController.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - 28).clamp(0.0, 414.0);

    return Container(
      width: cardWidth,
      // height: 172, // 建议去掉固定高度，让内容自适应
      margin: const EdgeInsets.only(left: 10, right: 10, top: 0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上半部分（商品信息）
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左侧：图片 + 名称 + 标签
                Row(
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
                    SizedBox(
                      width: 170,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.product.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2024)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(children: widget.product.tags.map((tag) => _TagPill(label: tag)).toList()),
                        ],
                      ),
                    ),
                  ],
                ),
                // 右侧：积分 + 市场价
                SizedBox(
                  width: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.product.points}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFFF2105)),
                          ),
                          const Text(
                            '积分',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFF2105)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '市场价:¥${widget.product.marketPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
                      ),
                    ],
                  ),
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
                    _QtyButton(label: '-', onTap: widget.onDecrement, isMinus: true),
                    Container(
                      width: 36,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border.symmetric(horizontal: BorderSide(color: Color(0xFFD9D9D9), width: 1.0)),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _qtyController,
                        focusNode: _focusNode,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1F2024),
                          height: 1.2, // 调整行高以辅助垂直居中
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          isCollapsed: true, // 进一步压缩内部空间
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onSubmitted: _onQuantitySubmitted,
                        onEditingComplete: () {
                          _onQuantitySubmitted(_qtyController.text);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    _QtyButton(label: '+', onTap: widget.onIncrement, isMinus: false),
                  ],
                ),

                const SizedBox(height: 12),

                // 第二行：留言备注
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '留言备注',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF1F2024)),
                    ),
                    const Text(
                      '请填写备注信息  >',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
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

class _QtyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isMinus;

  const _QtyButton({required this.label, required this.onTap, this.isMinus = false});

  @override
  Widget build(BuildContext context) {
    final borderRadius = isMinus
        ? const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))
        : const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 18,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F7),
          border: Border.all(color: const Color(0xFFD9D9D9)),
          borderRadius: borderRadius,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Color(0xFF000000), height: 1.0),
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
