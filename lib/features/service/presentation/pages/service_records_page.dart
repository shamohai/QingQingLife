import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../providers/reservation_record_provider.dart';
import '../widgets/reservation_record_card.dart';

/// 预约/报名记录子页面。
///
/// 接收 GoRouter query parameter 中的 activeTab，默认 ongoing。
/// 顶部两段纯文字分段标签（已预约 / 已结束），下方按当前 Tab 请求真实 API 数据。
///
/// 悬浮按钮组由父级 ServicePage 的 Stack 提供，本页面不重复引入。
class ServiceRecordsPage extends ConsumerWidget {
  /// 从路由参数中读取初始激活的 Tab，key 为 activeTab。
  final String activeTab;

  const ServiceRecordsPage({super.key, this.activeTab = 'ongoing'});

  /// tab key 对应的 reservationlisttype：
  ///   ongoing -> 1（已预约）
  ///   finished -> 2（已完成）
  int get _listType => activeTab == _TabKey.finished ? 2 : 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(myReservationListProvider(_listType));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text('预约/报名记录', style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // 全屏背景图
          Positioned.fill(
            child: Image.asset(
              'assets/images/service/service_record_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // 内容区
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildSegmentedTabs(context, activeTab),
                Expanded(
                  child: listAsync.when(
                    loading: () => const Center(child: AppLoading()),
                    error: (e, _) => Center(
                      child: AppError(
                        message: '加载失败，请稍后重试',
                        onRetry: () => ref.invalidate(myReservationListProvider(_listType)),
                      ),
                    ),
                    data: (items) => items.isEmpty
                        ? const SizedBox(height: 200, child: AppEmpty(message: '暂无记录'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) =>
                                ReservationRecordCard(
                                  item: items[index],
                                  onViewTap: () => context.push('/service/project/${items[index].serviceId}'),
                                ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 两段纯文字分段标签，带白色背景、底部圆角、激活态下划线。
  /// 切换时通过 pushReplacement 更新 query parameter，避免 Navigation Stack 持续膨胀。
  Widget _buildSegmentedTabs(BuildContext context, String activeTab) {
    const tabs = [(_TabKey.ongoing, '已预约'), (_TabKey.finished, '已结束')];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Row(
          children: tabs.map((tab) {
            final isActive = activeTab == tab.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  final uri = Uri.parse('/service/records').replace(queryParameters: {'activeTab': tab.$1});
                  context.pushReplacement(uri.toString());
                },
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
}

/// Tab 键常量（对应设计稿两态：已预约 / 已结束）
abstract final class _TabKey {
  static const String ongoing = 'ongoing';
  static const String finished = 'finished';
}
