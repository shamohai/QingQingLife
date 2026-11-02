import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/main_shell_scope.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../points_mall/presentation/widgets/points_floating_buttons.dart';
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
      if (!mounted) return;
      // 登录后 AuthNotifier._onLoginSuccess() 已触发 load()，
      // 仅在尚未加载时才补充一次拉取，避免重复请求。
      if (ref.read(sessionProvider) == SessionState.authenticated) {
        final profile = ref.read(userProfileProvider);
        if (!profile.hasLoaded) {
          ref.read(userProfileProvider.notifier).load();
        } else {
          ref.read(userProfileProvider.notifier).refreshCouponCount();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SessionState>(sessionProvider, (previous, next) {
      if (next == SessionState.authenticated && !ref.read(userProfileProvider).hasLoaded) {
        ref.read(userProfileProvider.notifier).load();
      } else if (next == SessionState.unauthenticated) {
        final profile = ref.read(userProfileProvider);
        if (profile.hasLoaded || profile.isLoading) {
          ref.read(userProfileProvider.notifier).clear();
        }
      }
    });

    final sessionState = ref.watch(sessionProvider);
    final profileState = ref.watch(userProfileProvider);
    final isAuthenticated = sessionState == SessionState.authenticated;
    final isLoading = sessionState == SessionState.loading || (isAuthenticated && !profileState.hasLoaded);
    // 主 Tab 内的底部导航已经处理系统安全区；独立页面才需要额外预留。
    final hasBottomNavigation = MainShellScope.hasBottomNavigationOf(context);
    final bottomSafeInset = hasBottomNavigation ? 0.0 : MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      // 页面底色与设计稿浅蓝背景一致
      backgroundColor: const Color(0xFFD6E8F7),
      body: isLoading
          ? const Center(child: AppLoading())
          : Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    if (ref.read(sessionProvider) == SessionState.authenticated) {
                      await ref.read(userProfileProvider.notifier).load();
                    }
                  },
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
                          // 背景保持通栏，内容避让状态栏、刘海和摄像头挖孔。
                          child: SafeArea(
                            top: true,
                            bottom: false,
                            child: Column(
                              children: [
                                const ProfileHeaderSection(),
                                if (isAuthenticated)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                    child: MemberSummaryCard(onTap: () => context.push(RouteNames.memberLevel)),
                                  ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                            ),
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
                        SizedBox(height: AppSpacing.xxl + bottomSafeInset),
                      ],
                    ),
                  ),
                ),

                // ── 首页同款管家服务悬浮按钮 ─────────────────────────────
                Positioned(
                  right: AppSpacing.lg,
                  bottom: AppSpacing.xl + bottomSafeInset,
                  child: SizedBox(key: const Key('profile_customer_service_button'), child: const PointsFloatingButtons()),
                ),
              ],
            ),
    );
  }
}
