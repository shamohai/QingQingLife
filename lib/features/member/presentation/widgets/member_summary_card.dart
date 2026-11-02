import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_image.dart';
import '../providers/member_level_provider.dart';
import '../providers/user_profile_provider.dart';

/// 会员等级信息卡片
///
/// 布局：等级名 + 「成长值/升级门槛」（左）+ 金色等级徽章（右），
/// 下方依次为权益提示、状态/到期时间与「立即签到」入口
/// （跳转会员签到页 RouteNames.memberSignIn）。
///
/// 不传 [level] 与 [growthValue] 时读取「我的」页会员状态；
/// 会员详情页则传入当前页签等级数据。传入 [onTap] 后支持整卡跳转。
class MemberSummaryCard extends ConsumerWidget {
  final MemberLevelOption? level;

  /// 用户当前成长值（来源「我的」页全局会员状态）
  final int? growthValue;

  /// 整卡点击回调；签到按钮会独立消费点击事件。
  final VoidCallback? onTap;

  const MemberSummaryCard({super.key, this.level, this.growthValue, this.onTap})
    : assert((level == null) == (growthValue == null), 'level and growthValue must be provided together');

  /// 权益数量中文数字（1~20），超出范围回退为阿拉伯数字
  static const List<String> _cnNumbers = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十', '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十'];

  static String _cnNum(int n) => n >= 0 && n <= 20 ? _cnNumbers[n] : '$n';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = level == null ? ref.watch(userProfileProvider) : null;
    final profileMode = profileState != null;
    final effectiveLevel =
        level ??
        MemberLevelOption(id: profileState!.currentRank?.userrid ?? 0, name: profileState.levelName, growthThreshold: profileState.nextLevelGrowthValue);
    final effectiveGrowthValue = growthValue ?? profileState!.growthValue;
    final reached = !profileMode && effectiveGrowthValue >= effectiveLevel.growthThreshold;
    final progressText = profileMode
        ? (effectiveLevel.growthThreshold > 0 ? '$effectiveGrowthValue/${effectiveLevel.growthThreshold}升级' : '已达成')
        : reached
        ? '已达成'
        : '$effectiveGrowthValue/${effectiveLevel.growthThreshold}升级';
    final benefitsText = profileMode ? '尊享多项会员权益，立即解锁' : '可尊享${_cnNum(effectiveLevel.cardBenefitsCount)}项会员权益';
    final statusText = profileMode ? _formatExpireDate(profileState.memberExpireDate) : (reached ? '已达到该等级，继续保持！' : '暂未达到该等级，怎能轻易认输！');
    final levelIconUrl = (level?.iconUrl ?? profileState?.levelIconUrl ?? '').trim();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDFEFE), Color(0xFFD3EBFB), Color(0xFF98D4F9)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── 左侧信息列 ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 等级名 + 成长值/门槛
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          effectiveLevel.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1B3C70), height: 1.1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        progressText,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2E7CD6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 权益提示
                  Row(
                    children: [
                      const Icon(Icons.diamond, size: 16, color: Color(0xFFE0A26E)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          benefitsText,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF3A4A5A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 状态/到期时间 + 立即签到入口
                  Row(
                    children: [
                      if (statusText.isNotEmpty)
                        Expanded(
                          child: Text(
                            statusText,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF94A7BC)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        const Spacer(),
                      const SizedBox(width: 8),
                      // GestureDetector(
                      //   onTap: () => context.push(RouteNames.memberSignIn),
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      //     decoration: const BoxDecoration(color: Color(0xFF0099FB), borderRadius: BorderRadius.all(Radius.circular(999))),
                      //     child: const Text(
                      //       '立即签到',
                      //       style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── 右侧等级徽章：我的页取 getmyprofile rankinfo.iconurl，详情页取等级详情图标 ──
            if (levelIconUrl.isNotEmpty)
              SizedBox(
                width: 84,
                height: 84,
                child: AppNetworkImage(url: levelIconUrl, fit: BoxFit.contain, memCacheWidth: 168, memCacheHeight: 168),
              )
            else if (!profileMode)
              const SizedBox(width: 84, height: 84)
            else
              Image.asset('assets/images/member/member_badge_level.webp', width: 84, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }

  static String _formatExpireDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}到期';
  }
}
