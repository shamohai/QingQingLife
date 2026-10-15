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
/// 数据来源：[UserProfileState]（等级 / 成长值 / 到期时间来自 getranklist 真实接口）
/// 点击卡片整体跳转至会员详情页（RouteNames.memberLevel）；
/// 「立即签到」按钮独立跳转至会员签到页（RouteNames.memberSignIn），不触发卡片跳转。
class ProfileMemberLevelCard extends ConsumerWidget {
  const ProfileMemberLevelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileProvider);

    // 防止除零
    final progress = state.nextLevelGrowthValue > 0 ? (state.growthValue / state.nextLevelGrowthValue).clamp(0.0, 1.0) : 0.0;
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
                          state.levelName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1B3C70), height: 1.1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.growthValue}/${state.nextLevelGrowthValue}升级',
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
                          '尊享多项会员权益，立即解锁',
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
                        onTap: () => context.push(RouteNames.memberSignIn),
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
