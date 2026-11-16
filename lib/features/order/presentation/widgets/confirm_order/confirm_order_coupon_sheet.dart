import 'package:flutter/material.dart';

/// 确认订单页优惠券底部弹层。
///
/// 商城普通订单的优惠券列表接口尚未对接，当前只展示空态，不渲染任何假优惠券。
class MallConfirmOrderCouponSheet extends StatelessWidget {
  const MallConfirmOrderCouponSheet({super.key, required this.bottomInset});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 17, 14, 0),
          child: SizedBox(
            height: 29,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text('选择优惠券', style: TextStyle(fontSize: 20, height: 1.4, color: Colors.black)),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '关闭',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    icon: Image.asset('assets/images/order/confirm-order-coupon-close.png', width: 24, height: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text('暂无可用优惠券', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
          ),
        ),
        SizedBox(height: bottomInset),
      ],
    );
  }
}
