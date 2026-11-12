import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../providers/confirm_order_provider.dart';
import 'confirm_order_money.dart';
import 'confirm_order_panel.dart';

/// 确认订单页金额卡片：发票、商品总价、运费、优惠券、合计。
class MallConfirmOrderAmountCard extends StatelessWidget {
  const MallConfirmOrderAmountCard({super.key, required this.state, required this.onInvoiceTap, required this.onCouponTap});

  final ConfirmOrderState state;
  final VoidCallback onInvoiceTap;
  final VoidCallback onCouponTap;

  @override
  Widget build(BuildContext context) {
    return MallConfirmOrderPanel(
      height: 217,
      padding: const EdgeInsets.fromLTRB(11, 14, 11, 18),
      child: Column(
        children: [
          _SummaryRow(label: '是否需要发票', value: state.needInvoice ? '已保存 >' : '去开票 >', onTap: onInvoiceTap),
          const SizedBox(height: 10),
          _SummaryRow(label: '商品总价', value: formatConfirmOrderMoney(state.productTotalCents), valueColor: const Color(0xFFFF2105)),
          const SizedBox(height: 10),
          _SummaryRow(label: '运费', value: formatConfirmOrderMoney(state.shippingFeeCents), valueColor: Colors.black),
          const SizedBox(height: 10),
          _SummaryRow(label: '选择优惠券', value: state.couponName == null ? '暂无可用券 >' : '${state.couponName}  >', onTap: onCouponTap),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE3E8F0)),
          const SizedBox(height: 15),
          _SummaryRow(
            label: '合计金额',
            value: formatConfirmOrderMoney(state.payableCents),
            labelWeight: FontWeight.w500,
            valueColor: const Color(0xFFFF2105),
            valueSize: 18,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.onTap,
    this.valueColor = const Color(0xFF8E8E93),
    this.valueSize = 16,
    this.labelWeight = FontWeight.w400,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final Color valueColor;
  final double valueSize;
  final FontWeight labelWeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        // Lock the design row height. Web CJK fonts can report a line box about
        // one pixel taller than fontSize * height, which accumulated across the
        // five rows and overflowed the fixed-height amount card.
        height: valueSize > 16 ? 27 : 24,
        child: Row(
          children: [
            Text(
              label,
              maxLines: 1,
              style: TextStyle(fontSize: 16, height: 1.5, fontWeight: labelWeight, color: Colors.black),
            ),
            const Spacer(),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: valueSize,
                  height: 1.5,
                  color: valueColor,
                  fontWeight: valueColor == AppColors.serviceButtonRed || valueColor == Colors.black ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
