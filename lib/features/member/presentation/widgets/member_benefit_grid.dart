import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../providers/member_level_provider.dart';
import 'member_benefit_lock_badge.dart';

/// 会员详情页 - 会员权益宫格（米橙色圆角卡片，3 列）
///
/// 设计稿：标题「会员享 18+ 项权益，立享尊贵」+ 副标 +
/// 3 列宫格（棕色圆形图标 + 权益名 + 灰色括号说明）。
/// hasowned=false 的权益在图标底部展示锁标识，点击只提示暂无权限。
///
/// 图标优先取 getrankdetail 的 services[].icon，接口未提供或加载失败时回退 Material 图标。
class MemberBenefitGrid extends StatelessWidget {
  final List<MemberBenefitItem> benefits;
  final Set<int> receivingServiceIds;
  final ValueChanged<MemberBenefitItem> onBenefitTap;

  const MemberBenefitGrid({super.key, required this.benefits, required this.receivingServiceIds, required this.onBenefitTap});

  static const Color _iconBg = Color(0xFF8A5A3C);
  static const Color _titleColor = Color(0xFF5C3A21);
  static const Color _subColor = Color(0xFFA5805B);

  /// 权益名 → 图标映射；未命中时回退钻石图标
  static const Map<String, IconData> _benefitIcons = {
    '生日好礼': Icons.cake,
    '生日好礼2': Icons.card_giftcard,
    '陪餐课': Icons.restaurant,
    '醒脚酒吧': Icons.local_bar,
    '美伦酒店': Icons.hotel,
    '接机&送机': Icons.flight_takeoff,
    '途虎': Icons.directions_car,
    '彩虹部落': Icons.attractions,
    '回厂游': Icons.factory,
    '100元': Icons.redeem,
    '50元': Icons.redeem,
    '视频会员': Icons.smart_display,
    '高尔夫跑团': Icons.golf_course,
    '网羽中心': Icons.sports_tennis,
    '露营基地': Icons.park,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFF8EA), Color(0xFFFFEAC8)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF6DDB4)),
      ),
      child: Column(
        children: [
          // ── 标题：会员享 18+ 项权益，立享尊贵 ────────────────────
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _titleColor, height: 1.3),
              children: [
                const TextSpan(text: '会员享'),
                TextSpan(
                  text: '${benefits.length}+',
                  style: const TextStyle(fontSize: 20, color: Color(0xFFFF6A1F)),
                ),
                const TextSpan(text: '项权益，立享尊贵'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            '入会即享多重礼遇，权益会心一处所有',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFFBE9364)),
          ),
          const SizedBox(height: 16),

          // ── 3 列宫格（按行组装，自然高度，无裁切风险）────────────
          ..._buildRows(),
        ],
      ),
    );
  }

  List<Widget> _buildRows() {
    final rows = <Widget>[];
    for (var i = 0; i < benefits.length; i += 3) {
      final chunk = benefits.sublist(i, (i + 3).clamp(0, benefits.length));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in chunk)
              Expanded(
                child: _BenefitCell(item: item, receiving: receivingServiceIds.contains(item.service.serviceid), onTap: () => onBenefitTap(item)),
              ),
            // 末行补齐占位，保持左对齐
            for (var j = chunk.length; j < 3; j++) const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 3 < benefits.length) {
        rows.add(const SizedBox(height: 16));
      }
    }
    return rows;
  }
}

/// 单个权益：棕色圆形图标 + 权益名 + 括号说明
class _BenefitCell extends StatelessWidget {
  final MemberBenefitItem item;
  final bool receiving;
  final VoidCallback onTap;

  const _BenefitCell({required this.item, required this.receiving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final auth = item.auth;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: receiving ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: receiving ? 0.55 : 1,
        child: Column(
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  _BenefitIcon(item: item, receiving: receiving),
                  if (!auth.isown) const Positioned(bottom: 0, child: MemberBenefitLockBadge()),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              auth.authname,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MemberBenefitGrid._titleColor, height: 1.2),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (auth.introduce.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '（${auth.introduce}）',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: MemberBenefitGrid._subColor, height: 1.3),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 权益图标：优先使用 getrankdetail 的 services[].icon，缺图时回退本地图标。
class _BenefitIcon extends StatelessWidget {
  final MemberBenefitItem item;
  final bool receiving;

  const _BenefitIcon({required this.item, required this.receiving});

  @override
  Widget build(BuildContext context) {
    final iconUrl = item.service.icon?.trim() ?? '';
    final fallback = Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(color: MemberBenefitGrid._iconBg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: receiving
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(MemberBenefitGrid._benefitIcons[item.auth.authname] ?? Icons.diamond_outlined, color: Colors.white, size: 22),
    );

    if (iconUrl.isEmpty) return fallback;

    return ClipOval(
      child: AppNetworkImage(url: iconUrl, width: 46, height: 46, fit: BoxFit.cover, memCacheWidth: 92, memCacheHeight: 92, errorWidget: fallback),
    );
  }
}
