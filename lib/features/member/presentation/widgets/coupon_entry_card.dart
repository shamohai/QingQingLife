import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../models/coupon_entry.dart';

/// 我的卡券页的券形入口卡片。
///
/// 左侧为浅色券面，右侧为高饱和操作区，左右缺口位于卡片中部。
class CouponEntryCard extends StatelessWidget {
  static const double _actionWidthFactor = 0.44;
  static const double _height = 86;

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
        child: SizedBox(
          height: _height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dividerX = constraints.maxWidth * (1 - _actionWidthFactor);
              return Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: entry.backgroundColors),
                          ),
                          child: Center(
                            child: Text(
                              entry.title,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: entry.titleColor, height: 1.2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 44,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: entry.actionColors),
                          ),
                          child: Center(
                            // 注意：不要给此 Container 同时设置 alignment 与 decoration，
                            // Align 会撑满父约束导致胶囊按钮被放大填满整个右段。
                            child: Container(
                              width: 94,
                              height: 33,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: entry.pillColors),
                                borderRadius: BorderRadius.circular(AppRadius.round),
                              ),
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
                  Positioned(
                    left: dividerX - 0.5,
                    top: 0,
                    bottom: 0,
                    child: ColoredBox(color: entry.dividerColor, child: const SizedBox(width: 1)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CouponCardClipper extends CustomClipper<Path> {
  const _CouponCardClipper();

  @override
  Path getClip(Size size) {
    const cornerRadius = 8.0;
    const notchRadius = 8.0;
    final outer = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(cornerRadius)));
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, size.height / 2), radius: notchRadius))
      ..addOval(Rect.fromCircle(center: Offset(size.width, size.height / 2), radius: notchRadius));
    return Path.combine(PathOperation.difference, outer, notches);
  }

  @override
  bool shouldReclip(covariant _CouponCardClipper oldClipper) => false;
}
