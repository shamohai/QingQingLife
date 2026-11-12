import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../providers/confirm_order_provider.dart';
import 'confirm_order_money.dart';
import 'confirm_order_panel.dart';

/// 确认订单页商品卡片：商品信息、数量步进器、留言备注。
class MallConfirmOrderProductCard extends StatelessWidget {
  const MallConfirmOrderProductCard({
    super.key,
    required this.state,
    required this.noteController,
    required this.onIncrement,
    required this.onDecrement,
    required this.onNoteChanged,
  });

  final ConfirmOrderState state;
  final TextEditingController noteController;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<String> onNoteChanged;

  @override
  Widget build(BuildContext context) {
    return MallConfirmOrderPanel(
      height: 172,
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 13),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.asset(state.product.imageUrl, width: 70, height: 70, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.product.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.product.skuName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, height: 1.2, color: Color(0xFF8E8E93)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatConfirmOrderMoney(state.product.priceCents),
                      style: const TextStyle(fontSize: 20, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.serviceButtonRed),
                    ),
                    const Text('¥900.00', style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF8E8E93))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: _QuantityStepper(quantity: state.quantity, onIncrement: onIncrement, onDecrement: onDecrement),
          ),
          const Spacer(),
          Row(
            children: [
              const Text('留言备注', style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
              const Spacer(),
              SizedBox(
                width: 133,
                height: 24,
                child: TextField(
                  controller: noteController,
                  onChanged: onNoteChanged,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  decoration: const InputDecoration(
                    hintText: '请填写备注信息 >',
                    hintStyle: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF8E8E93)),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onIncrement, required this.onDecrement});

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 24,
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/order/confirm-order-minus.png'), fit: BoxFit.fill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(label: '−', onTap: onDecrement),
          SizedBox(
            width: 20,
            child: Center(
              child: Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
          _StepperButton(label: '+', onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 20,
        height: 24,
        child: Center(
          child: Text(label, style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
