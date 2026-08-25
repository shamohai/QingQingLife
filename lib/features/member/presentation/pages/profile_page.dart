import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/member_profile_card.dart';
import '../widgets/points_coupon_card.dart';
import '../widgets/order_shortcuts.dart';
import '../widgets/member_kingkong.dart';
import '../widgets/settings_list.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authProvider);
    final sessionState = ref.watch(sessionProvider);

    if (authStatus == AuthStatus.unauthenticated ||
        sessionState == SessionState.unauthenticated) {
      return Scaffold(
        body: Center(
          child: GestureDetector(
            onTap: () => context.push(RouteNames.login),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.login_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  '请先登录',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverSafeArea(
            sliver: SliverToBoxAdapter(child: MemberProfileCard()),
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          SliverToBoxAdapter(child: PointsCouponCard()),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverToBoxAdapter(child: OrderShortcuts()),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverToBoxAdapter(child: MemberKingKong()),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: SettingsList(
                items: [
                  SettingItem(
                    icon: Icons.receipt_long_outlined,
                    title: '收支明细',
                    onTap: () => GoRouter.of(context).push(RouteNames.orders),
                  ),
                  SettingItem(
                    icon: Icons.info_outline,
                    title: '积分规则',
                    onTap: () {},
                  ),
                  SettingItem(
                    icon: Icons.event_available_outlined,
                    title: '活动列表',
                    onTap: () {},
                  ),
                  SettingItem(
                    icon: Icons.support_agent,
                    title: '专属管家服务',
                    onTap: () {},
                  ),
                  SettingItem(
                    icon: Icons.help_outline,
                    title: '客服中心',
                    onTap: () =>
                        GoRouter.of(context).push(RouteNames.customerService),
                  ),
                  SettingItem(
                    icon: Icons.settings_outlined,
                    title: 'App 设置',
                    onTap: () {},
                  ),
                  SettingItem(
                    icon: Icons.logout,
                    title: '退出登录',
                    subtitle: '安全退出当前账号',
                    onTap: () => _handleLogout(context, ref),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
            },
            child: const Text('退出', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
