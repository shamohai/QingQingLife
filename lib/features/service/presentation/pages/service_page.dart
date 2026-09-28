import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_empty.dart';
import '../providers/service_provider.dart';
import '../widgets/service_tab_bar.dart';
import '../widgets/service_list_item.dart';
import '../widgets/service_floating_buttons.dart';

class ServicePage extends ConsumerWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(serviceCardDataProvider);
    final selectedTab = ref.watch(selectedTabProvider);

    void onItemTap() => context.push(RouteNames.customerService);

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
                  child: cards.isEmpty
                      ? const SizedBox(height: 200, child: AppEmpty(message: '暂无服务'))
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          children: [
                            // 白色卡片容器，radius 10，包裹所有 ServiceListItem
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Column(
                                  children: [
                                    // 首项：上下 padding 14
                                    Padding(
                                      padding: const EdgeInsets.only(top: 14, bottom: 14),
                                      child: ServiceListItem(data: cards[0], onTap: onItemTap),
                                    ),
                                    // 中间项 + 末项：分割线 + 上下 padding 14
                                    for (int i = 1; i < cards.length; i++)
                                      Column(
                                        children: [
                                          Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 0, endIndent: 0),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 14, bottom: 14),
                                            child: ServiceListItem(data: cards[i], onTap: onItemTap),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          // 悬浮按钮组（绝对定位，不随列表滚动）
          const ServiceFloatingButtons(),
        ],
      ),
    );
  }
}
