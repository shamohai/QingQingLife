import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/service_provider.dart';
import '../widgets/service_tab_bar.dart';
import '../widgets/friend_activity_list_item.dart';
import '../widgets/offline_activity_list_item.dart';
import '../widgets/reservation_service_list_item.dart';
import '../widgets/service_floating_buttons.dart';
import '../widgets/share_cart_template_item.dart';

class ServicePage extends ConsumerStatefulWidget {
  /// AppBar/页面标题，由调用方传入（如上一页面点击的 id 对应的名称）
  final String? title;

  const ServicePage({super.key, this.title});

  @override
  ConsumerState<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends ConsumerState<ServicePage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialTab = ref.read(selectedTabProvider);
    _pageController = PageController(initialPage: _tabToIndex(initialTab));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);

    // Tab 切换时同步 PageView
    ref.listen<String>(selectedTabProvider, (_, next) {
      final index = _tabToIndex(next);
      if (_pageController.hasClients && _pageController.page?.round() != index) {
        _pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic);
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: AppColors.servicePageBackground,
        body: Stack(
          children: [
            Container(height: MediaQuery.paddingOf(context).top, color: Colors.white),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // 顶部固定 Tab 栏
                  ServiceTabBar(selectedTab: selectedTab, onTabChanged: (tab) => ref.read(selectedTabProvider.notifier).update(tab)),
                  // 可滚动内容区：PageView + AutomaticKeepAlive 真正保持 Widget 树不销毁
                  // 解决：图片零重建、滚动位置精确恢复、下拉刷新无手势冲突
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(), // 禁止左右滑动切换，只通过 Tab 栏切换
                      onPageChanged: (index) {
                        final tab = _indexToTab(index);
                        if (tab != selectedTab) {
                          ref.read(selectedTabProvider.notifier).update(tab);
                        }
                      },
                      children: const [
                        _FuwuTabBody(), // 0: 服务预约
                        _ZhiyouhuiTabBody(), // 1: 挚友报名会
                        _HuodongTabBody(), // 2: 活动报名
                        _GoujiuTabBody(), // 3: 购酒享服务
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const ServiceFloatingButtons(),
          ],
        ),
      ),
    );
  }
}

/// Tab 字符串 ↔ PageView 索引转换
int _tabToIndex(String tab) {
  switch (tab) {
    case 'zhiyouhui':
      return 1;
    case 'huodong':
      return 2;
    case 'goujiu':
      return 3;
    default:
      return 0; // fuwu
  }
}

String _indexToTab(int index) {
  switch (index) {
    case 1:
      return 'zhiyouhui';
    case 2:
      return 'huodong';
    case 3:
      return 'goujiu';
    default:
      return 'fuwu';
  }
}

/// ========== 以下为 4 个 Tab 的独立 KeepAlive Widget ==========

/// 服务预约 Tab（第 0 页）
class _FuwuTabBody extends ConsumerStatefulWidget {
  const _FuwuTabBody();

  @override
  ConsumerState<_FuwuTabBody> createState() => _FuwuTabBodyState();
}

class _FuwuTabBodyState extends ConsumerState<_FuwuTabBody> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _onItemTap(BuildContext context, String id) {
    context.push(RouteNames.reservationServiceDetail.replaceFirst(':id', id));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，启用 AutomaticKeepAlive
    final asyncList = ref.watch(reservationServiceListProvider);

    return asyncList.when(
      data: (services) {
        if (services.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(reservationServiceListProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 200, child: AppEmpty(message: '暂无服务'))],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(reservationServiceListProvider),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.compactPageMargin, vertical: AppSpacing.sm),
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 14),
                        child: ReservationServiceListItem(item: services[0], onBookTap: () => _onItemTap(context, services[0].serviceId.toString())),
                      ),
                      for (int i = 1; i < services.length; i++)
                        Column(
                          children: [
                            Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 16, endIndent: 14),
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                              child: ReservationServiceListItem(item: services[i], onBookTap: () => _onItemTap(context, services[i].serviceId.toString())),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const AppLoading(),
      error: (_, _) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(reservationServiceListProvider),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 200, child: AppEmpty(message: '加载失败，请重试'))],
        ),
      ),
    );
  }
}

/// 挚友报名会 Tab（第 1 页）
class _ZhiyouhuiTabBody extends ConsumerStatefulWidget {
  const _ZhiyouhuiTabBody();

  @override
  ConsumerState<_ZhiyouhuiTabBody> createState() => _ZhiyouhuiTabBodyState();
}

class _ZhiyouhuiTabBodyState extends ConsumerState<_ZhiyouhuiTabBody> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _onItemTap(BuildContext context, String id) {
    context.push(RouteNames.friendDetail.replaceFirst(':id', id));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final activitiesAsync = ref.watch(zhiyouhuiActivityListProvider);
    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(zhiyouhuiActivityListProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 200, child: AppEmpty(message: '暂无挚友报名会'))],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(zhiyouhuiActivityListProvider),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.compactPageMargin, vertical: AppSpacing.sm),
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 14),
                        child: FriendActivityListItem(item: activities[0], onTap: () => _onItemTap(context, activities[0].activityId)),
                      ),
                      for (int i = 1; i < activities.length; i++)
                        Column(
                          children: [
                            Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 16, endIndent: 14),
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                              child: FriendActivityListItem(item: activities[i], onTap: () => _onItemTap(context, activities[i].activityId)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const AppLoading(),
      error: (_, _) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(zhiyouhuiActivityListProvider),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 200, child: AppEmpty(message: '加载失败，请重试'))],
        ),
      ),
    );
  }
}

/// 活动报名 Tab（第 2 页）
class _HuodongTabBody extends ConsumerStatefulWidget {
  const _HuodongTabBody();

  @override
  ConsumerState<_HuodongTabBody> createState() => _HuodongTabBodyState();
}

class _HuodongTabBodyState extends ConsumerState<_HuodongTabBody> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _onItemTap(BuildContext context, String id) {
    context.push(RouteNames.activityDetail.replaceFirst(':id', id));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final activitiesAsync = ref.watch(offlineActivityListProvider);
    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(offlineActivityListProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 200, child: AppEmpty(message: '暂无活动'))],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(offlineActivityListProvider),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.compactPageMargin, vertical: AppSpacing.sm),
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 14),
                        child: OfflineActivityListItem(item: activities[0], onTap: () => _onItemTap(context, activities[0].activityId)),
                      ),
                      for (int i = 1; i < activities.length; i++)
                        Column(
                          children: [
                            Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 16, endIndent: 14),
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                              child: OfflineActivityListItem(item: activities[i], onTap: () => _onItemTap(context, activities[i].activityId)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const AppLoading(),
      error: (_, _) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(offlineActivityListProvider),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 200, child: AppEmpty(message: '加载失败，请重试'))],
        ),
      ),
    );
  }
}

/// 购酒享服务 Tab（第 3 页）
class _GoujiuTabBody extends ConsumerStatefulWidget {
  const _GoujiuTabBody();

  @override
  ConsumerState<_GoujiuTabBody> createState() => _GoujiuTabBodyState();
}

class _GoujiuTabBodyState extends ConsumerState<_GoujiuTabBody> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final templatesAsync = ref.watch(shareCartTemplateProvider);
    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(shareCartTemplateProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                Center(
                  child: SizedBox(height: 200, child: AppEmpty(message: '暂无购酒享服务')),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(shareCartTemplateProvider),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.compactPageMargin, vertical: AppSpacing.sm),
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 14),
                        child: ShareCartTemplateItem(
                          template: templates[0],
                          onTap: () => context.push(RouteNames.serviceTemplateDetailPath(templateId: templates[0].templateId)),
                        ),
                      ),
                      for (int i = 1; i < templates.length; i++)
                        Column(
                          children: [
                            Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 0, endIndent: 0),
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                              child: ShareCartTemplateItem(
                                template: templates[i],
                                onTap: () => context.push(RouteNames.serviceTemplateDetailPath(templateId: templates[i].templateId)),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const AppLoading(),
      error: (_, _) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(shareCartTemplateProvider),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            Center(
              child: SizedBox(height: 200, child: AppEmpty(message: '加载失败，请重试')),
            ),
          ],
        ),
      ),
    );
  }
}
