import '''package:flutter/material.dart''';
import '''package:flutter_riverpod/flutter_riverpod.dart''';
import '''package:go_router/go_router.dart''';

import '''../../../../app/router/route_names.dart''';
import '''../../../../core/providers/session_provider.dart''';
import '''../providers/user_profile_provider.dart''';
import '''../widgets/user_info_card.dart''';
import '''../widgets/monthly_benefits_card.dart''';
import '''../widgets/points_coupon_card.dart''';
import '''../widgets/order_shortcuts.dart''';
import '''../widgets/butler_services_section.dart''';
import '''../widgets/recommend_products_section.dart''';
import '''../../../auth/presentation/providers/auth_provider.dart''';

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
                Icon(Icons.login_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 12),
                Text('''请先登录''', style: const TextStyle(fontSize: 16, color: Color(0xFF444843))),
              ],
            ),
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).load();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverToBoxAdapter(child: UserInfoCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverToBoxAdapter(child: MonthlyBenefitsCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverToBoxAdapter(child: PointsCouponCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverToBoxAdapter(child: OrderShortcuts()),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverToBoxAdapter(child: ButlerServicesSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          const SliverToBoxAdapter(child: RecommendProductsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
