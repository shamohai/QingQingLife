import 'package:flutter/material.dart';

import 'confirm_order_panel.dart';

/// 确认订单页支付方式卡片（当前仅微信支付）。
class MallConfirmOrderPaymentCard extends StatelessWidget {
  const MallConfirmOrderPaymentCard({super.key, required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MallConfirmOrderPanel(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Image.asset('assets/images/order/confirm-order-wechat.png', width: 26, height: 26),
            const SizedBox(width: 10),
            const Text(
              '微信支付',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (selected) Image.asset('assets/images/order/confirm-order-selected.png', width: 20, height: 20),
          ],
        ),
      ),
    );
  }
}
