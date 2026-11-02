import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/service_provider.dart';
import '../widgets/service_tab_bar.dart';
import '../widgets/friend_activity_list_item.dart';
import '../widgets/huodong_activity_list_item.dart';
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

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 顶部固定 Tab 栏
                ServiceTabBar(selectedTab: selectedTab, onTabChanged: (tab) => ref.read(selectedTabProvider.notifier).update(tab)),
                // 可滚动内容区
                Expanded(
                  child: switch (selectedTab) {
                    'huodong' => _buildHuodongBody(ref, onItemTap),
                    'goujiu' => _buildGoujiuBody(context, ref),
                    'zhiyouhui' => _buildZhiyouhuiBody(ref, onItemTap),
                    _ => _buildFuwuBody(ref, onItemTap),
                  },
                ),
              ],
            ),
          ),
          const ServiceFloatingButtons(),
        ],
      ),
    );
  }

  /// 活动报名列表（第三个 tab）：使用真实 API 数据
  Widget _buildHuodongBody(WidgetRef ref, void Function(String) onItemTap) {
    final activitiesAsync = ref.watch(huodongActivityListProvider);
    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return const SizedBox(height: 200, child: AppEmpty(message: '暂无活动'));
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 14),
                      child: HuodongActivityListItem(item: activities[0], onTap: () => onItemTap(activities[0].activityId)),
                    ),
                    for (int i = 1; i < activities.length; i++)
                      Column(
                        children: [
                          Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 16, endIndent: 14),
                          Padding(
                            padding: const EdgeInsets.only(top: 14, bottom: 14),
                            child: HuodongActivityListItem(item: activities[i], onTap: () => onItemTap(activities[i].activityId)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const AppLoading(),
      error: (_, _) => const SizedBox(height: 200, child: AppEmpty(message: '加载失败，请重试')),
    );
  }

  /// 服务预约列表（第一个 tab）：列表项点击跳转到详情页
  Widget _buildFuwuBody(WidgetRef ref, void Function(String) onItemTap) {
    final asyncList = ref.watch(reservationServiceListProvider);

    return asyncList.when(
      data: (services) {
        if (services.isEmpty) {
          return const SizedBox(height: 200, child: AppEmpty(message: '暂无服务'));
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11),
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
        );
      },
      loading: () => const AppLoading(),
      error: (_, _) => const SizedBox(height: 200, child: AppEmpty(message: '加载失败，请重试')),
    );
  }

  /// 挚友报名会列表（第二个 tab）：使用真实 API 数据
  Widget _buildZhiyouhuiBody(WidgetRef ref, void Function(String) onItemTap) {
    final activitiesAsync = ref.watch(zhiyouhuiActivityListProvider);
    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return const SizedBox(height: 200, child: AppEmpty(message: '暂无挚友报名会'));
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11),
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
        );
      },
      loading: () => const AppLoading(),
      error: (_, _) => const SizedBox(height: 200, child: AppEmpty(message: '加载失败，请重试')),
    );
  }

  Widget _buildGoujiuBody(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(shareCartTemplateProvider);
    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return const Center(child: AppEmpty(message: '暂无购酒享服务'));
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11),
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
        );
      },
      loading: () => const AppLoading(),
      error: (_, _) => const Center(child: AppEmpty(message: '加载失败，请重试')),
    );
  }
}
