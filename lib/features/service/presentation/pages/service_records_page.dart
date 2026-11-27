import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../providers/offline_activity_record_provider.dart';
import '../../domain/models/offline_activity_record_item.dart';
import '../../../../core/presentation/paging/paging_list_view.dart';
import '../providers/reservation_record_provider.dart';
import '../widgets/offline_activity_record_card.dart';
import '../widgets/reservation_record_card.dart';

/// 预约/报名记录子页面。
///
/// 单级 Tab 结构：
///   Tab 1：服务预约 - 调用现有 API，reservationlisttype=0 (全部)
///   Tab 2：活动报名 - 调用 getmyofflineactivitylist，卡片样式同预约记录卡片
///
/// 使用 IndexedStack + keepAlive 保持 Tab 状态（滚动位置、数据缓存），避免切换时重新加载。
/// 仅当数据为空时才重新加载。
class ServiceRecordsPage extends ConsumerWidget {
  /// 当前选中的 Tab：'reservation' (服务预约) | 'activity' (活动报名)
  final String activeTab;

  const ServiceRecordsPage({super.key, this.activeTab = 'reservation'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(serviceRecordsTabProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => context.pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
        title: Text('预约/报名记录', style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // 全屏背景图
          Positioned.fill(child: Image.asset('assets/images/service/service_record_bg.png', fit: BoxFit.cover)),
          // 内容区
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 单级 Tab：服务预约 / 活动报名
                _buildTabs(context, ref, selectedTab),
                // 列表内容：IndexedStack 保持两个 Tab 状态
                Expanded(
                  child: IndexedStack(
                    index: selectedTab == 'reservation' ? 0 : 1,
                    children: [
                      _buildReservationList(ref), // 0: 服务预约
                      _buildActivityList(context, ref), // 1: 活动报名
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tab 栏：服务预约 / 活动报名
  Widget _buildTabs(BuildContext context, WidgetRef ref, String selectedTab) {
    const tabs = [('reservation', '服务预约记录'), ('activity', '活动报名记录')];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Row(
          children: tabs.map((tab) {
            final isActive = selectedTab == tab.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => ref.read(serviceRecordsTabProvider.notifier).update(tab.$1),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tab.$2,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 16,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? AppColors.serviceTabActive : AppColors.serviceTabInactive,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isActive)
                          Container(
                            width: 24,
                            height: 3,
                            decoration: BoxDecoration(color: AppColors.serviceTabActive, borderRadius: BorderRadius.circular(999)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 服务预约列表（调用真实 API，reservationlisttype=0 全部）
  Widget _buildReservationList(WidgetRef ref) {
    final listAsync = ref.watch(myReservationListProvider);

    return listAsync.when(
      loading: () => const Center(child: AppLoading()),
      error: (e, _) => Center(
        child: AppError(message: '加载失败，请稍后重试', onRetry: () => ref.invalidate(myReservationListProvider)),
      ),
      data: (items) {
        // 空数据时显示空状态，并提供下拉刷新
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myReservationListProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 200, child: AppEmpty(message: '暂无记录'))],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myReservationListProvider),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => ReservationRecordCard(
              item: items[index],
              onViewTap: () => context.push(
                Uri(
                  path: RouteNames.serviceBookingRecordDetail,
                  queryParameters: {'id': items[index].reservationId.toString(), 'type': 'reservation'},
                ).toString(),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 活动报名记录列表（getmyofflineactivitylist，卡片样式同预约记录卡片）
  Widget _buildActivityList(BuildContext context, WidgetRef ref) {
    return PagingListView<OfflineActivityRecordItem>(
      provider: myOfflineActivityRecordProvider,
      loadingWidget: const SizedBox(height: 200, child: Center(child: AppLoading())),
      errorWidget: Center(
        child: AppError(message: '加载失败，请稍后重试', onRetry: () => ref.invalidate(myOfflineActivityRecordProvider)),
      ),
      emptyWidget: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myOfflineActivityRecordProvider),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 200, child: AppEmpty(message: '暂无记录'))],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      separatorBuilder: const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, item, index) => OfflineActivityRecordCard(
        item: item,
        onViewTap: () =>
            context.push(Uri(path: RouteNames.serviceBookingRecordDetail, queryParameters: {'id': item.activityId, 'type': 'activity'}).toString()),
      ),
    );
  }
}

/// 记录页面当前选中的 Tab Provider（保持缓存避免 Tab 切换重复请求）
final serviceRecordsTabProvider = NotifierProvider<ServiceRecordsTabNotifier, String>(() => ServiceRecordsTabNotifier());

class ServiceRecordsTabNotifier extends Notifier<String> {
  @override
  String build() => 'reservation';

  void update(String tab) => state = tab;
}
