import 'package:flutter/material.dart';

/// 确认订单页优惠券底部弹层。
class MallConfirmOrderCouponSheet extends StatelessWidget {
  const MallConfirmOrderCouponSheet({super.key, required this.bottomInset, required this.onUse});

  final double bottomInset;
  final VoidCallback onUse;

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
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: _CouponCard(available: true, onUse: onUse),
        ),
        const SizedBox(height: 12),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: _CouponCard(available: false)),
        SizedBox(height: bottomInset),
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.available, this.onUse});

  final bool available;
  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) {
    final color = available ? const Color(0xFFFF2105) : const Color(0xFF8E8E93);
    return SizedBox(
      height: 110,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              available ? 'assets/images/order/confirm-order-coupon-available.png' : 'assets/images/order/confirm-order-coupon-unavailable.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: color, fontFamily: 'PingFang HK', fontWeight: FontWeight.w600),
                      children: const [
                        TextSpan(text: '¥', style: TextStyle(fontSize: 16, height: 1)),
                        TextSpan(text: '50', style: TextStyle(fontSize: 32, height: 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('新人优惠券', style: TextStyle(fontSize: 14, height: 1.4, color: color)),
                ],
              ),
            ),
            Container(width: 1, height: 65, color: available ? const Color(0xFFFF5D18) : color),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '新人优惠券50元',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w500, color: color),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '有效期:2026.6.7—2026.10.1',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, height: 1.4, color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: available ? 84 : 82,
              height: 30,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: available ? null : const Color(0xFFC6C6C6),
                  gradient: available
                      ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFF5D18), Color(0xFFFF9147)])
                      : null,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TextButton(
                  onPressed: available ? onUse : null,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, disabledForegroundColor: Colors.white, shape: const StadiumBorder()),
                  child: Text(available ? '使用' : '不可用', style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
