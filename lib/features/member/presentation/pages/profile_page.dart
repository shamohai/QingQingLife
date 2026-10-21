import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/profile_butler_banner.dart';
import '../widgets/profile_feature_grid.dart';
import '../widgets/profile_footer.dart';
import '../widgets/profile_header_section.dart';
import '../widgets/member_summary_card.dart';
import '../widgets/profile_order_shortcuts.dart';
import '../widgets/profile_stats_card.dart';

/// 「我的」页面
///
/// 页面结构（自顶向下）：
///   顶部渐变背景区（HeaderSection + MemberLevelCard）
///   → StatsCard → OrderShortcuts → ButlerBanner → FeatureGrid → Footer
///   右下角浮动客服按钮（Stack 悬浮层）
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 登录后 AuthNotifier._onLoginSuccess() 已触发 load()，
      // 仅在尚未加载（初始空态）时才补充一次拉取，避免重复请求。
      final profile = ref.read(userProfileProvider);
      if (profile.levelName == "未登录" && profile.nickname == "青轻用户_9527") {
        ref.read(userProfileProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);

    return Scaffold(
      // 页面底色与设计稿浅蓝背景一致
      backgroundColor: const Color(0xFFD6E8F7),
      body: profileState.levelName == '未登录'
          ? const Center(child: AppLoading())
          : Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async => ref.read(userProfileProvider.notifier).load(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // ── 顶部渐变背景区：用户信息 + 会员等级卡片 ──────
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0, 0.55, 1],
                              colors: [Color(0xFF8FB7FD), Color(0xFFA9DEFA), Color(0xFFD6E8F7)],
                            ),
                          ),
                          child: Column(
                            children: [
                              const ProfileHeaderSection(),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                child: MemberSummaryCard(onTap: () => context.push(RouteNames.memberLevel)),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                          ),
                        ),

                        // ── 资产统计卡片 ─────────────────────────────────
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: ProfileStatsCard(),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // ── 我的订单 ─────────────────────────────────────
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: ProfileOrderShortcuts(),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // ── 管家服务 Banner ──────────────────────────────
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: ProfileButlerBanner(),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // ── 常用功能宫格 ─────────────────────────────────
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: ProfileFeatureGrid(),
                        ),

                        // ── 退出登录 ─────────────────────────────────────
                        const ProfileFooter(),

                        // 底部留白，避免内容贴底
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),

                // ── 浮动客服按钮 ────────────────────────────────────────
                Positioned(
                  right: AppSpacing.lg,
                  bottom: AppSpacing.xl,
                  child: GestureDetector(
                    onTap: () => context.push(RouteNames.customerService),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: Color(0xFF2456A6), shape: BoxShape.circle),
                      child: const Icon(Icons.headset_mic, size: 24, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
