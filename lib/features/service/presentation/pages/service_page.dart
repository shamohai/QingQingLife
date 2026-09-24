import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
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

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // TabBar：固定高度 44，不随列表滚动
                ServiceTabBar(
                  selectedTab: selectedTab,
                  onTabChanged: (tab) => ref.read(selectedTabProvider.notifier).update(tab),
                ),
                // 白色内容卡片容器，水平 margin 16，圆角 12，带轻微阴影
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x08000000),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: cards.isEmpty
                        ? const AppEmpty(message: '暂无服务')
                        : ListView.separated(
                            padding: const EdgeInsets.only(top: AppSpacing.md),
                            itemCount: cards.length,
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              color: AppColors.serviceDivider,
                              thickness: 1,
                            ),
                            itemBuilder: (context, index) => ServiceListItem(
                              data: cards[index],
                              onTap: () => context.push(RouteNames.customerService),
                            ),
                          ),
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




