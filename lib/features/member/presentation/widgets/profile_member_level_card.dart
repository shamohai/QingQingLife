import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../providers/user_profile_provider.dart';

/// 会员等级卡片
///
/// 布局：等级名称 + 成长值进度（左）+ 等级徽章（右），
/// 下方依次为权益提示、立即签到按钮与等级到期时间。
/// 数据来源：[UserProfileState.memberInfo] / [UserProfileState.benefitsCount]
/// 点击卡片整体跳转至会员详情页（RouteNames.memberLevel）；
/// 「立即签到」按钮独立处理，不触发跳转。
class ProfileMemberLevelCard extends ConsumerWidget {
  const ProfileMemberLevelCard({super.key});

  /// 权益数量中文数字（1~10），超出范围回退为阿拉伯数字
  static const List<String> _cnNumbers = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];

  static String _cnNum(int n) => n >= 0 && n <= 10 ? _cnNumbers[n] : '$n';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileProvider);
    final info = state.memberInfo;

    // 防止除零
    final progress = info.nextLevelGrowthValue > 0 ? (info.growthValue / info.nextLevelGrowthValue).clamp(0.0, 1.0) : 0.0;
    final expireDate = state.memberExpireDate;

    return GestureDetector(
      onTap: () => context.push(RouteNames.memberLevel),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.md, AppSpacing.lg),
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFDFEFE), Color(0xFFD3EBFB), Color(0xFF98D4F9)]),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── 左侧信息列 ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 等级名 + 成长值
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          info.levelName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1B3C70), height: 1.1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${info.growthValue}/${info.nextLevelGrowthValue}升级',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF33475B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 成长值进度条
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFCBE0F5),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7CD6)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 权益提示
                  Row(
                    children: [
                      const Icon(Icons.diamond, size: 16, color: Color(0xFFE0A26E)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '可尊享${_cnNum(state.benefitsCount)}项会员权益',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF3A4A5A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 签到按钮 + 到期时间
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: 签到接口后端暂未提供，待接入后补充
                          debugPrint('[ProfileMemberLevelCard] 立即签到点击');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: const BoxDecoration(color: Color(0xFF0099FB), borderRadius: BorderRadius.all(Radius.circular(999))),
                          child: const Text(
                            '立即签到',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (expireDate != null)
                        Text(
                          '${expireDate.year}-${expireDate.month.toString().padLeft(2, '0')}-${expireDate.day.toString().padLeft(2, '0')}到期',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF5F7E9C)),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── 右侧等级徽章 ──────────────────────────────────────────
            Image.asset('assets/images/member/member_badge_level.webp', width: 76, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
