import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_spacing.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_banner.dart';
import '../widgets/home_kingkong_grid.dart';
import '../widgets/home_new_user_gift_card.dart';
import '../widgets/home_hot_products.dart';
import '../widgets/home_topic_banner.dart';
import '../widgets/home_product_grid.dart';
import '../providers/home_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.read(homeDataProvider).banners;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: HomeAppBar()),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: HomeBanner(imageUrls: banners.map((b) => b.imageUrl).toList()),
                ),
                const SizedBox(height: AppSpacing.lg),
                const HomeKingKongGrid(),
                const SizedBox(height: AppSpacing.lg),
                const HomeNewUserGiftCard(),
                const SizedBox(height: AppSpacing.lg),
                const HomeHotProducts(),
                const SizedBox(height: AppSpacing.lg),
                const HomeTopicBanner(),
                const SizedBox(height: AppSpacing.lg),
                const HomeProductGrid(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}