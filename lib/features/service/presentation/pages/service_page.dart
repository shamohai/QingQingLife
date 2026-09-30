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
import '../widgets/share_cart_template_item.dart';

class ServicePage extends ConsumerWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    void onBookTap(String id, {bool isGoujiu = false}) {
      if (isGoujiu) {
        context.push(RouteNames.serviceTemplateDetail.replaceFirst(':id', id));
      } else {
        context.push(RouteNames.serviceProjectDetail.replaceFirst(':id', id));
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
                Expanded(child: selectedTab == 'goujiu' ? _buildGoujiuBody(context, ref) : _buildOtherBody(ref, onBookTap)),
              ],
            ),
          ),
          // 悬浮按钮组（绝对定位，不随列表滚动）
          const ServiceFloatingButtons(),
        ],
      ),
    );
  }

  Widget _buildOtherBody(WidgetRef ref, void Function(String, {bool isGoujiu}) onBookTap) {
    final cards = ref.watch(serviceCardDataProvider);
    return cards.isEmpty
        ? const SizedBox(height: 200, child: AppEmpty(message: '暂无服务'))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 14),
                        child: ServiceListItem(data: cards[0], onBookTap: onBookTap),
                      ),
                      for (int i = 1; i < cards.length; i++)
                        Column(
                          children: [
                            Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 0, endIndent: 0),
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                              child: ServiceListItem(data: cards[i], onBookTap: onBookTap),
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
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
      loading: () => const Center(child: SizedBox(height: 200, child: CircularProgressIndicator())),
      error: (_, _) => const Center(child: AppEmpty(message: '加载失败，请重试')),
    );
  }
}
