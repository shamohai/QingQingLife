import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../app/router/route_names.dart';
import '../../domain/models/service_record_item.dart';
import '../providers/service_provider.dart';
import '../widgets/service_entry_card.dart';

/// 预约/报名记录子页面。
///
/// 接收 GoRouter extra / Navigator arguments 中的 [activeTab]，默认 'ongoing'。
/// 顶部三段标签（进行中 / 已结束 / 即将开始），下方按当前 Tab 过滤渲染卡片列表。
class ServiceRecordsPage extends ConsumerWidget {
  /// 从路由参数中读取初始激活的 Tab，key 为 'activeTab'。
  final String activeTab;

  const ServiceRecordsPage({
    super.key,
    this.activeTab = 'ongoing',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItems = ref.watch(serviceRecordDataProvider);

    final filteredItems = activeTab == 'ongoing'
        ? allItems
        : allItems.where((item) => item.status == activeTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '预约/报名记录',
          style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 无 AppBar，顶部直接放置纯文字分段标签
          const SizedBox(height: AppSpacing.sm),
          _buildSegmentedTabs(context, ref, activeTab),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: filteredItems.isEmpty
                ? const AppEmpty(message: '暂无记录')
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _RecordCard(item: item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 三段纯文字标签，无背景容器，选中加粗
  Widget _buildSegmentedTabs(
    BuildContext context,
    WidgetRef ref,
    String activeTab,
  ) {
    const tabs = [
      (_TabKey.ongoing, '进行中'),
      (_TabKey.ended, '已结束'),
      (_TabKey.upcoming, '即将开始'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.map((tab) {
          final isActive = activeTab == tab.$1;
          return GestureDetector(
            onTap: () {
              // 通过路由重新推送带新参数的页面，刷新列表
              context.push(
                Uri(
                  path: RouteNames.serviceRecords,
                  queryParameters: {'activeTab': tab.$1},
                ).toString(),
              );
            },
            child: Text(
              tab.$2,
              style: AppTextStyles.labelLarge.copyWith(
                color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Tab 键常量
abstract final class _TabKey {
  static const String ongoing = 'ongoing';
  static const String ended = 'ended';
  static const String upcoming = 'upcoming';
}

/// 记录列表中的卡片：复用 ServiceEntryCard 样式，buttonText 固定为"去预约"
class _RecordCard extends StatelessWidget {
  final ServiceRecordItem item;

  const _RecordCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ServiceEntryCard(
      title: item.title,
      buttonText: '去预约',
      listMode: item.status,
    );
  }
}
