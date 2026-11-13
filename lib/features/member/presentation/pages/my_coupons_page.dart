import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../models/coupon_entry.dart';
import '../widgets/coupon_entry_card.dart';

/// 我的卡券页（/coupons）
///
/// 结构（设计稿）：
///   浅灰背景 → 返回栏「我的卡券」→ 三个双段券形入口
///   → 「更多福利卡敬请期待…」→ 底部湖景背景。
///
/// 三类入口均已接入对应列表页。
class MyCouponsPage extends StatelessWidget {
  const MyCouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F7),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Image.asset('assets/images/member/about_lake_bg.png', width: double.infinity, fit: BoxFit.fitWidth),
              ),
            ),
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildNavBar(context),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(
                        children: [
                          for (var i = 0; i < CouponEntry.all.length; i++) ...[
                            CouponEntryCard(entry: CouponEntry.all[i], onTap: () => _onCouponEntryTap(context, CouponEntry.all[i])),
                            if (i != CouponEntry.all.length - 1) const SizedBox(height: AppSpacing.lg),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 54),
                    const Text(
                      '更多福利卡敬请期待…',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF000000), size: 22),
            onPressed: () => context.pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text(
            '我的卡券',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF000000), height: 1.2),
          ),
        ],
      ),
    );
  }

  void _onCouponEntryTap(BuildContext context, CouponEntry entry) {
    if (entry.type == CouponEntryType.discount) {
      context.push(RouteNames.couponList);
      return;
    }
    if (entry.type == CouponEntryType.service) {
      context.push(RouteNames.serviceCouponList);
      return;
    }
    if (entry.type == CouponEntryType.lockedRedPacket) {
      context.push(RouteNames.lockedRedPacketList);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${entry.title}列表页待接入'), behavior: SnackBarBehavior.floating));
  }
}
