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
                // TabBar：固定高度 44，白色背景，底部圆角
                ServiceTabBar(
                  selectedTab: selectedTab,
                  onTabChanged: (tab) => ref.read(selectedTabProvider.notifier).update(tab),
                ),
                // 内容区域：透明背景，ListView 直接滚动
                Flexible(
                  fit: FlexFit.loose,
                  child: cards.isEmpty
                      ? const SizedBox(
                          height: 200,
                          child: AppEmpty(message: '暂无服务'),
                        )
                      : ListView.separated(
                          itemCount: cards.length,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          // 不设置 shrinkWrap，让 ListView 自适应高度
                          // 不设置 physics，使用默认的 BouncingScrollPhysics
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.servicePageBackground,
                            indent: AppSpacing.lg,
                            endIndent: AppSpacing.lg,
                          ),
                          itemBuilder: (context, index) => ServiceListItem(
                            data: cards[index],
                            onTap: () => context.push(RouteNames.customerService),
                            isFirst: index == 0,
                            isLast: index == cards.length - 1,
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

