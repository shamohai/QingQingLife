import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../domain/models/service_card_data.dart';
import '../../domain/models/share_cart_template_model.dart';
import '../providers/service_provider.dart';
import '../widgets/service_tab_bar.dart';
import '../widgets/service_list_item.dart';
import '../widgets/service_floating_buttons.dart';

class ServicePage extends ConsumerWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    // goujiu tab 使用真实 API 数据，其他 tab 继续用 mock
    final cards = selectedTab == 'goujiu'
        ? _goujiuCardsFromApi(ref)
        : ref.watch(serviceCardDataProvider);

    void onBookTap(String serviceId, {bool isGoujiu = false}) {
      if (isGoujiu) {
        context.push(RouteNames.serviceTemplateDetail.replaceFirst(':id', serviceId));
      } else {
        context.push(RouteNames.serviceProjectDetail.replaceFirst(':id', serviceId));
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
                                      child: ServiceListItem(data: cards[0], onBookTap: (id) => onBookTap(id, isGoujiu: selectedTab == 'goujiu')),
                                    ),
                                    // 中间项 + 末项：分割线 + 上下 padding 14
                                    for (int i = 1; i < cards.length; i++)
                                      Column(
                                        children: [
                                          Divider(height: 1, thickness: 0.5, color: AppColors.serviceDivider, indent: 0, endIndent: 0),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 14, bottom: 14),
                                            child: ServiceListItem(
                                              data: cards[i],
                                              onBookTap: (id) => onBookTap(id, isGoujiu: selectedTab == 'goujiu'),
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

  /// 将 API 模板列表转换为 ServiceCardData 供 ServiceListItem 展示
  List<ServiceCardData> _goujiuCardsFromApi(WidgetRef ref) {
    final templates = ref.watch(shareCartTemplateProvider);
    return templates.when(
      data: (list) => list.map(_templateToCard).toList(),
      loading: () => const [],
      error: (_, _) => const [],
    );
  }

  ServiceCardData _templateToCard(ShareCartTemplate t) {
    final subtitle = t.requirements.isNotEmpty ? t.requirements : '点击查看详情';
    return ServiceCardData(
      id: t.templateId.toString(),
      imageAsset: kNetworkImageFallback,
      title: t.templateName,
      subtitle: subtitle,
      buttonText: '立即购买',
      tabKey: 'goujiu',
    );
  }

  /// 网络图片无法本地加载时的 fallback asset
  static const kNetworkImageFallback = 'assets/images/service/service_goujiu.webp';
}
