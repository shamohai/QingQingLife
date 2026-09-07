import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/providers/session_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/user_info_card.dart';
import '../widgets/monthly_benefits_card.dart';
import '../widgets/points_coupon_card.dart';
import '../widgets/order_shortcuts.dart';
import '../widgets/butler_services_section.dart';
import '../widgets/recommend_products_section.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authProvider);
    final sessionState = ref.watch(sessionProvider);

    // 1. 未登录状态拦截
    if (authStatus == AuthStatus.unauthenticated || sessionState == SessionState.unauthenticated) {
      return Scaffold(
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque, // 扩大全屏点击热区
            onTap: () => context.push(RouteNames.login),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(
                    '请先登录',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface, // 适配深色模式
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 2. 登录成功后，监听登录状态变化来加载数据，替代原本引发死循环的 addPostFrameCallback
    // 只有当登录状态从“未登录”变为“已登录”时，这里才会安全地触发一次 load
    ref.listen(authProvider, (previous, next) {
      if (next == AuthStatus.authenticated) {
        ref.read(userProfileProvider.notifier).load();
      }
    });

    // 3. 已登录状态的页面布局
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '我的',
          style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // 将顶部的标准垂直卡片合并，提升长列表滚动时的性能
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const UserInfoCard(),
                const SizedBox(height: AppSpacing.sm),
                const MonthlyBenefitsCard(),
                const SizedBox(height: AppSpacing.sm),
                const PointsCouponCard(),
                const SizedBox(height: AppSpacing.sm),
                const OrderShortcuts(),
                const SizedBox(height: AppSpacing.sm),
                const ButlerServicesSection(),
                const SizedBox(height: AppSpacing.md),
              ]),
            ),
          ),
          // 如果推荐商品部分内部自带了复杂的 GridView/ListView，保留独立的 Sliver 方便嵌套
          const SliverToBoxAdapter(child: RecommendProductsSection()),
          // 底部留白
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}
