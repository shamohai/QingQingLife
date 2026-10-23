import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/coupon_entry.dart';

/// 我的卡券页的券形入口卡片。
class CouponEntryCard extends StatelessWidget {
  final CouponEntry entry;
  final VoidCallback onTap;

  const CouponEntryCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _CouponCardClipper(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: entry.gradientColors),
          ),
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      entry.title,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: entry.buttonTextColor, height: 1.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                _Perforation(color: entry.borderColor),
                SizedBox(
                  width: 104,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: entry.buttonColor, borderRadius: BorderRadius.circular(999)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 6),
                        child: Text(
                          '立即查看',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: entry.buttonTextColor, height: 1.2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Perforation extends StatelessWidget {
  final Color color;

  const _Perforation({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      child: CustomPaint(painter: _PerforationPainter(color: color)),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  final Color color;

  const _PerforationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.65)
      ..strokeWidth = 1;
    const dashHeight = 4.0;
    const gapHeight = 4.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0.5, y), Offset(0.5, math.min(y + dashHeight, size.height)), paint);
      y += dashHeight + gapHeight;
    }
  }

  @override
  bool shouldRepaint(covariant _PerforationPainter oldDelegate) => oldDelegate.color != color;
}

class _CouponCardClipper extends CustomClipper<Path> {
  const _CouponCardClipper();

  @override
  Path getClip(Size size) {
    const notchRadius = 7.0;
    const cornerRadius = 7.0;
    final path = Path()
      ..moveTo(cornerRadius, 0)
      ..lineTo(size.width - cornerRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, cornerRadius)
      ..lineTo(size.width, size.height / 2 - notchRadius)
      ..arcToPoint(Offset(size.width, size.height / 2 + notchRadius), radius: const Radius.circular(notchRadius), clockwise: false)
      ..lineTo(size.width, size.height - cornerRadius)
      ..quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height)
      ..lineTo(cornerRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - cornerRadius)
      ..lineTo(0, size.height / 2 + notchRadius)
      ..arcToPoint(Offset(0, size.height / 2 - notchRadius), radius: const Radius.circular(notchRadius), clockwise: false)
      ..lineTo(0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
