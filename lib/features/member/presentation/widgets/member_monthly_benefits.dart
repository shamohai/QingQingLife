import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../providers/member_level_provider.dart';

/// 会员详情页 - 每月权益（白色圆角卡片，横向滚动的权益券）
///
/// 设计稿：标题行「🎁 每月权益 (权益月月享，每月只可领取一个)」，
/// 下方为横向滚动的券面 + 橙色「领取」按钮。
///
/// 数据：来自 getRankDetail（POST /api/sys/app/getrankdetail）的 monthlyproductlist，
/// 券面标题/副标题绑定 productname / servicedescr，领取状态绑定 isreceived。
///
/// TODO: 券面图（设计切图/后端 productimg）资源尚未提供，当前使用 Flutter 原生样式券面还原；
/// 资源就绪后替换为 AppNetworkImage。领取接口（ReceiveUserService）后端未实现，暂记录日志。
class MemberMonthlyBenefits extends StatelessWidget {
  final List<MemberMonthlyCoupon> coupons;

  const MemberMonthlyBenefits({super.key, required this.coupons});

  /// 券面示例配色（对齐设计稿券面色调：红/橙/蓝/绿品牌色）
  static const List<List<Color>> _couponGradients = [
    [Color(0xFFFF5A4D), Color(0xFFE8352E)],
    [Color(0xFFFF7A45), Color(0xFFFF3D2E)],
    [Color(0xFFFF8A3D), Color(0xFFFF5A1F)],
    [Color(0xFF4D8DFF), Color(0xFF2E6BE8)],
    [Color(0xFFFFA13F), Color(0xFFFF7A1F)],
    [Color(0xFF3DBD7D), Color(0xFF2E9E5E)],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 标题行 ────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.card_giftcard, size: 18, color: Color(0xFFFF9D2E)),
              const SizedBox(width: 4),
              const Text(
                '每月权益',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1D1C)),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '(权益月月享，每月只可领取一个)',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Color(0xFF999999)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── 横向滚动券面 ─────────────────────────────────────────
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: coupons.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _CouponItem(coupon: coupons[index], gradient: _couponGradients[index % _couponGradients.length]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 单张权益券：券面 + 领取按钮
class _CouponItem extends StatelessWidget {
  final MemberMonthlyCoupon coupon;
  final List<Color> gradient;

  const _CouponItem({required this.coupon, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 券面 ──────────────────────────────────────────────────
        Container(
          width: 92,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                coupon.title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                coupon.subtitle,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w400, color: Color(0xE6FFFFFF)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── 领取按钮（已领取时置灰并展示「已领取」）─────────────────
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: coupon.received
              ? null
              : () {
                  // TODO: 每月权益领取接口（ReceiveUserService）后端未实现，待接入后补充
                  debugPrint('[MemberMonthlyBenefits] 领取点击: ${coupon.title}');
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            decoration: BoxDecoration(
              color: coupon.received ? const Color(0xFFC9CDD4) : const Color(0xFFFF8C1F),
              borderRadius: const BorderRadius.all(Radius.circular(999)),
            ),
            child: Text(
              coupon.received ? '已领取' : '领取',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, height: 1.3),
            ),
          ),
        ),
      ],
    );
  }
}
