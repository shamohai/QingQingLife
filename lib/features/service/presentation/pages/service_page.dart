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

class ServicePage extends ConsumerWidget {
  /// AppBar/页面标题，由调用方传入（如上一页面点击的 id 对应的名称）
  final String? title;

  const ServicePage({super.key, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    // 列表项点击 → 根据当前 Tab 跳转到对应详情页
    void onItemTap(String id) {
      final selectedTab = ref.read(selectedTabProvider);
      switch (selectedTab) {
        case 'fuwu':
          context.push(RouteNames.reservationServiceDetail.replaceFirst(':id', id));
          break;
        case 'zhiyouhui':
          context.push(RouteNames.friendDetail.replaceFirst(':id', id));
          break;
        case 'huodong':
          context.push(RouteNames.activityDetail.replaceFirst(':id', id));
          break;
        default:
          context.push(RouteNames.reservationServiceDetail.replaceFirst(':id', id));
      }
    }

    // Tab 顺序索引：0=服务预约, 1=挚友报名会, 2=活动报名, 3=购酒享服务
    int tabIndex(String tab) {
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
                  // 可滚动内容区：使用 IndexedStack 保持所有 Tab 状态（滚动位置、图片渲染、Item 状态），避免切换时重建
                  Expanded(
                    child: IndexedStack(
                      index: tabIndex(selectedTab),
                      children: [
                        _buildFuwuBody(ref, onItemTap), // 0: 服务预约
                        _buildZhiyouhuiBody(ref, onItemTap), // 1: 挚友报名会
                        _buildOfflineActivityBody(ref, onItemTap), // 2: 活动报名
                        _buildGoujiuBody(context, ref), // 3: 购酒享服务
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

  /// 活动报名列表（第三个 tab）：使用真实 API 数据
  Widget _buildOfflineActivityBody(WidgetRef ref, void Function(String) onItemTap) {
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
                        child: OfflineActivityListItem(item: activities[0], onTap: () => onItemTap(activities[0].activityId)),
                      ),
                      for (int i = 1; i < activities.length; i++)
                        Column(
                          children: [
                            Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 16, endIndent: 14),
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                              child: OfflineActivityListItem(item: activities[i], onTap: () => onItemTap(activities[i].activityId)),
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

  /// 服务预约列表（第一个 tab）：列表项点击跳转到详情页
  Widget _buildFuwuBody(WidgetRef ref, void Function(String) onItemTap) {
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
                        child: ReservationServiceListItem(item: services[0], onBookTap: () => onItemTap(services[0].serviceId.toString())),
                      ),
                      for (int i = 1; i < services.length; i++)
                        Column(
                          children: [
                            Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 16, endIndent: 14),
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                              child: ReservationServiceListItem(item: services[i], onBookTap: () => onItemTap(services[i].serviceId.toString())),
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

  /// 挚友报名会列表（第二个 tab）：使用真实 API 数据
  Widget _buildZhiyouhuiBody(WidgetRef ref, void Function(String) onItemTap) {
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
                        child: FriendActivityListItem(item: activities[0], onTap: () => onItemTap(activities[0].activityId)),
                      ),
                      for (int i = 1; i < activities.length; i++)
                        Column(
                          children: [
                            Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 16, endIndent: 14),
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                              child: FriendActivityListItem(item: activities[i], onTap: () => onItemTap(activities[i].activityId)),
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

  Widget _buildGoujiuBody(BuildContext context, WidgetRef ref) {
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
