import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/service_provider.dart';
import '../widgets/service_tab_bar.dart';
import '../widgets/service_list_item.dart';
import '../widgets/reservation_service_list_item.dart';
import '../widgets/service_activity_card_item.dart';
import '../widgets/service_floating_buttons.dart';
import '../widgets/share_cart_template_item.dart';

class ServicePage extends ConsumerWidget {
  /// AppBar/页面标题，由调用方传入（如上一页面点击的 id 对应的名称）
  final String? title;

  const ServicePage({super.key, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final isHuodong = selectedTab == 'huodong';

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
          // 悬浮按钮组（huodong tab 不显示）
          if (!isHuodong) const ServiceFloatingButtons(),
        ],
      ),
    );
  }

  /// 活动报名列表（第三个 tab）：列表项点击跳转到详情页
  Widget _buildHuodongBody(WidgetRef ref, void Function(String) onItemTap) {
    final cards = ref.watch(serviceCardDataProvider);
    return cards.isEmpty
        ? const SizedBox(height: 200, child: AppEmpty(message: '暂无活动'))
        : ListView(
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
                        child: ServiceActivityCardItem(data: cards[0], onTap: () => onItemTap(cards[0].id)),
                      ),
                      for (int i = 1; i < cards.length; i++)
                        Column(
                          children: [
                            Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 16, endIndent: 14),
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                              child: ServiceActivityCardItem(data: cards[i], onTap: () => onItemTap(cards[i].id)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
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

  /// 挚友报名会列表（第二个 tab）：列表项点击跳转到详情页
  /// 样式与服务预约一致，分离便于后续独立扩展
  Widget _buildZhiyouhuiBody(WidgetRef ref, void Function(String) onItemTap) {
    final cards = ref.watch(serviceCardDataProvider);
    return cards.isEmpty
        ? const SizedBox(height: 200, child: AppEmpty(message: '暂无挚友报名会'))
        : ListView(
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
                        child: ServiceListItem(data: cards[0], onBookTap: onItemTap),
                      ),
                      for (int i = 1; i < cards.length; i++)
                        Column(
                          children: [
                            Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 16, endIndent: 14),
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                              child: ServiceListItem(data: cards[i], onBookTap: onItemTap),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
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
                        onTap: () => context.push(RouteNames.serviceTemplateDetail.replaceFirst(':id', templates[0].templateId.toString())),
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
                              onTap: () => context.push(RouteNames.serviceTemplateDetail.replaceFirst(':id', templates[i].templateId.toString())),
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
