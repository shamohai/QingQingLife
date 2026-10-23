import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../data/models/coupon_group_model.dart';

/// 单一状态优惠券卡片。
class CouponGroupCard extends StatelessWidget {
  final CouponGroupInfo coupon;
  final VoidCallback? onTap;
  final String typeLabel;
  final String? actionLabelOverride;
  final CouponGroupStatus? statusOverride;

  const CouponGroupCard({super.key, required this.coupon, this.onTap, this.typeLabel = '优惠券', this.actionLabelOverride, this.statusOverride});

  @override
  Widget build(BuildContext context) {
    final style = _CouponCardStyle.fromStatus(statusOverride ?? coupon.status);

    return ClipPath(
      clipper: const _CouponCardClipper(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 108,
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: style.backgroundColors),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: style.actionColors),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _CouponBorderPainter(color: style.borderColor)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 13, 0, 13),
                child: Row(
                  children: [
                    SizedBox(
                      width: 82,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            typeLabel,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: style.primaryTextColor, height: 1.2),
                          ),
                          const SizedBox(height: 6),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '剩余',
                                  style: TextStyle(color: style.secondaryTextColor),
                                ),
                                TextSpan(
                                  text: '${coupon.count}',
                                  style: TextStyle(color: style.remainingCountColor, fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: '张',
                                  style: TextStyle(color: style.secondaryTextColor),
                                ),
                              ],
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, height: 1.2),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coupon.couponName.isEmpty ? '优惠券' : coupon.couponName,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: style.primaryTextColor, height: 1.2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _amountText(coupon),
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: style.amountColor, height: 1.15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _validityText(coupon),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: style.secondaryTextColor, height: 1.2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: Center(
                        child: Text(
                          _verticalText(actionLabelOverride ?? style.actionLabel),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: style.actionTextColor, height: 1.05),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _amountText(CouponGroupInfo coupon) {
    if (coupon.money > Decimal.zero) return '¥${coupon.money.toStringAsFixed(2)}';
    if (coupon.discount > 0) return '${coupon.discount}折';
    return '';
  }

  static String _validityText(CouponGroupInfo coupon) {
    final start = _formatDate(coupon.startTime);
    final end = _formatDate(coupon.endTime);
    if (start.isEmpty && end.isEmpty) return '';
    if (start.isEmpty) return '有效期至$end';
    if (end.isEmpty) return '有效期$start起';
    return '有效期$start至$end';
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _verticalText(String value) {
    return value.runes.map(String.fromCharCode).where((char) => char.trim().isNotEmpty).join('\n');
  }
}

class _CouponCardStyle {
  final List<Color> backgroundColors;
  final List<Color> actionColors;
  final Color actionTextColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color amountColor;
  final Color remainingCountColor;
  final Color borderColor;
  final String actionLabel;

  const _CouponCardStyle({
    required this.backgroundColors,
    required this.actionColors,
    required this.actionTextColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.amountColor,
    required this.remainingCountColor,
    required this.borderColor,
    required this.actionLabel,
  });

  static _CouponCardStyle fromStatus(CouponGroupStatus status) {
    return switch (status) {
      CouponGroupStatus.valid => const _CouponCardStyle(
        backgroundColors: [Color(0xFFCFE1FA), Color(0xFFE2ECFF)],
        actionColors: [Color(0xFF6C9ADB), Color(0xFF5C8FD2)],
        actionTextColor: Colors.white,
        primaryTextColor: Color(0xFF2D5EAB),
        secondaryTextColor: Color(0xFF9AA9BD),
        amountColor: Color(0xFFE13232),
        remainingCountColor: Color(0xFFE13232),
        borderColor: Color(0xFFC1D6F3),
        actionLabel: '去使用',
      ),
      CouponGroupStatus.transferring => const _CouponCardStyle(
        backgroundColors: [Color(0xFFC7DDF8), Color(0xFFE0EBFF)],
        actionColors: [Color(0xFF82ADE7), Color(0xFF9CBEEC)],
        actionTextColor: Colors.white,
        primaryTextColor: Color(0xFF2E5FAE),
        secondaryTextColor: Color(0xFF9AA9BD),
        amountColor: Color(0xFFE13232),
        remainingCountColor: Color(0xFF2E5FAE),
        borderColor: Color(0xFFBCD1EE),
        actionLabel: '转赠中',
      ),
      CouponGroupStatus.used => const _CouponCardStyle(
        backgroundColors: [Color(0xFFF0F0F0), Color(0xFFE4E4E4)],
        actionColors: [Color(0xFFD1D1D1), Color(0xFFC2C2C2)],
        actionTextColor: Color(0xFFF0F0F0),
        primaryTextColor: Color(0xFF999999),
        secondaryTextColor: Color(0xFFB0B0B0),
        amountColor: Color(0xFFB0B0B0),
        remainingCountColor: Color(0xFFB0B0B0),
        borderColor: Color(0xFFD4D4D4),
        actionLabel: '查看详情',
      ),
      CouponGroupStatus.expired => const _CouponCardStyle(
        backgroundColors: [Color(0xFFF0F0F0), Color(0xFFE4E4E4)],
        actionColors: [Color(0xFFD1D1D1), Color(0xFFC2C2C2)],
        actionTextColor: Color(0xFFF0F0F0),
        primaryTextColor: Color(0xFF999999),
        secondaryTextColor: Color(0xFFB0B0B0),
        amountColor: Color(0xFFB0B0B0),
        remainingCountColor: Color(0xFFB0B0B0),
        borderColor: Color(0xFFD4D4D4),
        actionLabel: '已过期',
      ),
    };
  }
}

class _CouponCardClipper extends CustomClipper<Path> {
  const _CouponCardClipper();

  @override
  Path getClip(Size size) => _buildCouponPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _CouponBorderPainter extends CustomPainter {
  final Color color;

  const _CouponBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(_buildCouponPath(size), paint);
  }

  @override
  bool shouldRepaint(covariant _CouponBorderPainter oldDelegate) => oldDelegate.color != color;
}

Path _buildCouponPath(Size size) {
  const actionWidth = 72.0;
  const cornerRadius = 8.0;
  const notchRadius = 7.0;
  final dividerX = size.width - actionWidth;
  final outer = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(cornerRadius)));
  final notches = Path()
    ..addOval(Rect.fromCircle(center: Offset(dividerX, 0), radius: notchRadius))
    ..addOval(Rect.fromCircle(center: Offset(dividerX, size.height), radius: notchRadius));
  return Path.combine(PathOperation.difference, outer, notches);
}
