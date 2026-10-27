import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qingqinglife/app/theme/app_spacing.dart';
import 'package:qingqinglife/features/points_mall/presentation/widgets/points_floating_buttons.dart';

import '../../../product/domain/repositories/product_repository.dart' as repo;
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../app/router/route_names.dart';
import '../widgets/home_banner.dart' as home_widgets;
import '../widgets/home_kingkong_grid.dart';
import '../widgets/home_monthly_benefits.dart';
import '../widgets/home_hot_products.dart';
import '../widgets/home_activity_section.dart';
import '../widgets/home_topic_activity_section.dart';
import '../widgets/home_bottom_recommend_section.dart';
import '../../data/providers/home_carousel_provider.dart';
import '../providers/home_paging_providers.dart';

class _HomeStringSetNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void add(String id) {
    state = <String>{...state, id};
  }

  void remove(String id) {
    state = <String>{...state}..remove(id);
  }
}

class _HomeActiveUserServiceIdNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int id) {
    state = id;
  }
}

/// 首页每月权益领取中 ID 集合 Provider
final homeClaimingIdsProvider = NotifierProvider.autoDispose<_HomeStringSetNotifier, Set<String>>(
  _HomeStringSetNotifier.new,
);

/// 首页当月激活的 userServiceId（>0 表示当月已成功领取）
final homeActiveUserServiceIdProvider = NotifierProvider.autoDispose<_HomeActiveUserServiceIdNotifier, int>(
  _HomeActiveUserServiceIdNotifier.new,
);

/// 首页静态数据 Provider（金刚区、新人礼、专题、每月权益、可用商品、活动模块）
/// 轮播图由独立的 homeCarouselProvider 提供
final homeStaticDataProvider = FutureProvider<HomeStaticData>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final response = await repository.getHomeProductData();
  if (!response.success || response.data == null) {
    throw Exception(response.message);
  }
  final data = response.data!;
  return HomeStaticData(
    kingKongItems: data.kingKongItems,
    newUserGifts: data.newUserGifts,
    monthlyBenefits: data.monthlyBenefits,
    hotProducts: data.hotProducts,
    hotSearchKeywords: data.hotSearchKeywords,
    topicActivities: data.topicActivities,
    activityBlocks: data.activityBlocks,
    topicActivityBlocks: data.topicActivityBlocks,
  );
});

/// 首页静态聚合数据
class HomeStaticData {
  final List<repo.HomeKingKongItem> kingKongItems;
  final List<repo.HomeNewUserGift> newUserGifts;
  final List<repo.HomeMonthlyBenefit> monthlyBenefits;
  final List<repo.ProductCard> hotProducts;
  final List<String> hotSearchKeywords;
  final Map<String, String> topicActivities;
  final List<repo.HomeActivityBlock> activityBlocks;
  final List<repo.HomeTopicActivityBlock> topicActivityBlocks;

  const HomeStaticData({
    required this.kingKongItems,
    required this.newUserGifts,
    required this.monthlyBenefits,
    required this.hotProducts,
    required this.hotSearchKeywords,
    required this.topicActivities,
    required this.activityBlocks,
    required this.topicActivityBlocks,
  });
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staticDataAsync = ref.watch(homeStaticDataProvider);
    final carouselAsync = ref.watch(homeCarouselProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF213775),
      body: Stack(
        children: [
          staticDataAsync.when(
            loading: () => const Center(child: AppLoading()),
            error: (error, stackTrace) => Center(
              child: AppError(message: '加载失败: $error', onRetry: () => ref.invalidate(homeStaticDataProvider)),
            ),
            data: (staticData) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(homeStaticDataProvider);
                ref.invalidate(homeCarouselProvider);
                await ref.read(homeStaticDataProvider.future);
                await ref.read(homeCarouselProvider.future);
                await ref.read(homeRecommendCreditProductsProvider.notifier).refresh();
              },
              color: const Color(0xFF213775),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    final metrics = notification.metrics;
                    if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                      ref.read(homeRecommendCreditProductsProvider.notifier).loadMore();
                    }
                  }
                  return false;
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    // 顶部栏：Logo + 搜索框 + 消息
                    // const SliverToBoxAdapter(child: HomeAppBar()),

                    // Banner（轮播图，真实 API 数据）
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 2, bottom: 4),
                      sliver: SliverToBoxAdapter(
                        child: carouselAsync.when(
                          data: (banners) => home_widgets.HomeBanner(banners: banners),
                          loading: () => const SizedBox(height: 220),
                          error: (_, _) => const SizedBox(height: 220),
                        ),
                      ),
                    ),

                    // // White Card 1: 新人礼 + 可用商品 ,暂时注释掉
                    // SliverPadding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    //   sliver: SliverToBoxAdapter(
                    //     child: HomePromoSection(gifts: staticData.newUserGifts, products: staticData.hotProducts),
                    //   ),
                    // ),

                    // White Card 2: 金刚区 (10项 2x5 网格)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      sliver: SliverToBoxAdapter(child: HomeKingKongGrid(items: staticData.kingKongItems)),
                    ),

                    // White Card 3: 每月权益
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      sliver: SliverToBoxAdapter(
                        child: Consumer(
                          builder: (context, ref, child) {
                            final claimingIds = ref.watch(homeClaimingIdsProvider);
                            final activeUserServiceId = ref.watch(homeActiveUserServiceIdProvider);

                            return HomeMonthlyBenefits(
                              benefits: staticData.monthlyBenefits,
                              claimingIds: claimingIds,
                              activeUserServiceId: activeUserServiceId,
                              onImageTap: (benefit) {
                                final effectiveUserServiceId = activeUserServiceId > 0 ? activeUserServiceId : benefit.userServiceId;
                                final effectiveIsClaimed = effectiveUserServiceId > 0 || benefit.isReceived;
                                final effectiveSettlemented = benefit.settlemented;

                                if (effectiveIsClaimed && !effectiveSettlemented) {
                                  // 状态 2：当月已领取未兑换/未核销 -> 点击图片跳转到确认订单页
                                  final path = '${RouteNames.confirmOrder.replaceFirst(':id', benefit.id)}?userServiceId=$effectiveUserServiceId';
                                  GoRouter.of(context).push(path);
                                } else {
                                  // 状态 1 (未领取) 或 状态 3 (已兑换/已发货/已核销) -> 跳转到积分商品详情页
                                  final path = RouteNames.serviceProductDetail.replaceFirst(':id', benefit.id);
                                  GoRouter.of(context).push(path);
                                }
                              },
                              onClaimTap: (benefit) async {
                                final effectiveUserServiceId = activeUserServiceId > 0 ? activeUserServiceId : benefit.userServiceId;
                                final effectiveIsClaimed = effectiveUserServiceId > 0 || benefit.isReceived;
                                final effectiveSettlemented = benefit.settlemented;

                                if (effectiveIsClaimed && !effectiveSettlemented) {
                                  // 状态 2：点击【去兑换】-> 直接跳转到确认订单页
                                  final path = '${RouteNames.confirmOrder.replaceFirst(':id', benefit.id)}?userServiceId=$effectiveUserServiceId';
                                  GoRouter.of(context).push(path);
                                  return;
                                }

                                if (effectiveIsClaimed && effectiveSettlemented) {
                                  // 状态 3：已兑换/已发货/已核销，按钮不可点击
                                  return;
                                }

                                // 状态 1：当月未领取 -> 调 receiveUserService 接口
                                final serviceIdInt = benefit.serviceId > 0 ? benefit.serviceId : (int.tryParse(benefit.id) ?? 0);
                                if (serviceIdInt <= 0) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('无效的权益ID')),
                                  );
                                  return;
                                }

                                final claimingNotifier = ref.read(homeClaimingIdsProvider.notifier);
                                final claiming = ref.read(homeClaimingIdsProvider);
                                if (claiming.contains(benefit.id)) return;

                                claimingNotifier.add(benefit.id);
                                try {
                                  final response = await ref.read(memberRepositoryProvider).receiveUserService(serviceId: serviceIdInt);
                                  if (!context.mounted) return;
                                  if (response.code == 107 || response.message.contains('请登录')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('请先登录')),
                                    );
                                    GoRouter.of(context).push(RouteNames.login);
                                    return;
                                  }
                                  if (!response.success || response.data == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(response.message.isNotEmpty ? response.message : '领取失败，请稍后重试')),
                                    );
                                    return;
                                  }

                                  final result = response.data!;
                                  final newUserServiceId = result.userServiceId;

                                  if (newUserServiceId > 0) {
                                    // 1. 更新本地激活状态（当月已领取，所有卡片变去兑换/按钮状态刷新）
                                    ref.read(homeActiveUserServiceIdProvider.notifier).set(newUserServiceId);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('领取成功')),
                                    );

                                    // 2. 紧接着跳转到确认订单页
                                    final confirmPath = '${RouteNames.confirmOrder.replaceFirst(':id', benefit.id)}?userServiceId=$newUserServiceId';
                                    GoRouter.of(context).push(confirmPath);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(result.isDuplicate ? '该权益当月已领取' : '领取失败，未获取到有效权益')),
                                    );
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('领取异常: $e')),
                                  );
                                } finally {
                                  claimingNotifier.remove(benefit.id);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // White Card 4: 热卖商品
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      sliver: SliverToBoxAdapter(child: HomeHotProducts()),
                    ),

                    // White Card 5: 线上活动 (2大图并排)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      sliver: SliverToBoxAdapter(child: HomeActivitySection(blocks: staticData.activityBlocks)),
                    ),

                    // White Card 6: 线下活动 (3图并排) - 仅在有数据时渲染
                    if (staticData.topicActivityBlocks.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        sliver: SliverToBoxAdapter(child: HomeTopicActivitySection(blocks: staticData.topicActivityBlocks)),
                      ),

                    // 底部商品展示区 (推荐青稞粒商品列表，支持滚动加载)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      sliver: SliverToBoxAdapter(child: HomeBottomRecommendSection()),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 15)),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(right: AppSpacing.lg, bottom: 20, child: PointsFloatingButtons()),
        ],
      ),
    );
  }
}
