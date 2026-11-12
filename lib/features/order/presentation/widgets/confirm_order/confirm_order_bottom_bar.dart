import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../providers/confirm_order_provider.dart';
import 'confirm_order_money.dart';

/// 确认订单页底部栏：应付金额、减免提示、提交按钮。
class MallConfirmOrderBottomBar extends StatelessWidget {
  const MallConfirmOrderBottomBar({super.key, required this.state, required this.onSubmit});

  final ConfirmOrderState state;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final amount = formatConfirmOrderMoney(state.payableCents).substring(1).split('.');
    return Container(
      height: 80 + MediaQuery.paddingOf(context).bottom,
      padding: EdgeInsets.fromLTRB(20, 13, 12, MediaQuery.paddingOf(context).bottom + 13),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Keep the amount on one line on narrow phones; the source layout
                // assumes a wider frame, so scale only this compact summary when needed.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: RichText(
                    maxLines: 1,
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style.copyWith(color: Colors.black, fontSize: 14, height: 1),
                      children: [
                        const TextSpan(text: '合计：'),
                        const TextSpan(
                          text: '¥',
                          style: TextStyle(color: Color(0xFFFE273D), fontSize: 16, height: 1, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: '${amount.first}.',
                          style: const TextStyle(color: Color(0xFFFE273D), fontSize: 24, height: 1, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: amount.last,
                          style: const TextStyle(color: Color(0xFFFE273D), fontSize: 16, height: 1, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('共减免${(state.couponDiscountCents / 100).toStringAsFixed(0)}元', style: const TextStyle(fontSize: 12, color: Color(0xFFFF2105))),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 156,
            height: 47,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.serviceTabActive, AppColors.serviceCtaGradStart]),
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextButton(
                onPressed: onSubmit,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  state.isSubmitting ? '提交中...' : '提交订单',
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
