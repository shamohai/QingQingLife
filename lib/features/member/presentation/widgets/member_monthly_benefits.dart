import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../providers/member_level_provider.dart';

/// 会员详情页 - 每月权益（白色圆角卡片，横向滚动的权益券）
///
/// 设计稿：标题行「🎁 每月权益 (权益月月享，每月只可领取一个)」，
/// 下方为横向滚动的券面 + 橙色「领取」按钮。
///
/// 数据：来自 getRankDetail（POST /api/sys/app/getrankdetail）的 monthlyproductlist，
/// 券面绑定 ServiceProductItem 的 productname / servicedescr，领取状态绑定 isreceived。
///
/// TODO: 券面图（设计切图/后端 productimg）资源尚未提供，当前使用 Flutter 原生样式券面还原；
/// 资源就绪后替换为 AppNetworkImage。领取通过 ReceiveUserService 完成。
class MemberMonthlyBenefits extends ConsumerWidget {
  final List<MemberMonthlyCoupon> coupons;
  final Future<void> Function(MemberMonthlyCoupon coupon) onCouponTap;

  const MemberMonthlyBenefits({super.key, required this.coupons, required this.onCouponTap});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final receivingServiceIds = ref.watch(memberLevelProvider.select((state) => state.receivingServiceIds));
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
                return _CouponItem(
                  coupon: coupons[index],
                  gradient: _couponGradients[index % _couponGradients.length],
                  receiving: receivingServiceIds.contains(coupons[index].serviceId),
                  onReceive: () => onCouponTap(coupons[index]),
                );
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
  final bool receiving;
  final VoidCallback? onReceive;

  const _CouponItem({required this.coupon, required this.gradient, required this.receiving, required this.onReceive});

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
                coupon.productName,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                coupon.serviceDescr,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w400, color: Color(0xE6FFFFFF)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── 领取 / 去使用按钮 ─────────────────────────────────────
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: receiving ? null : onReceive,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            decoration: BoxDecoration(
              color: receiving
                  ? const Color(0xFFC9CDD4)
                  : coupon.isReceived
                  ? const Color(0xFF4D8DFF)
                  : const Color(0xFFFF8C1F),
              borderRadius: const BorderRadius.all(Radius.circular(999)),
            ),
            child: Text(
              receiving ? '处理中' : (coupon.isReceived ? '去使用' : '领取'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, height: 1.3),
            ),
          ),
        ),
      ],
    );
  }
}
