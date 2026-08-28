import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty.dart';
import '../providers/service_provider.dart';

class ServicePage extends ConsumerWidget {
  const ServicePage({super.key});

  static const _tabs = ['进行中', '已结束', '即将开始', '预约/报名记录'];
  static const _statusKeys = ['ongoing', 'ended', 'upcoming', 'record'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(serviceTabProvider);
    final allItems = ref.watch(serviceDataProvider);

    final filteredItems = activeTab == 'ongoing'
        ? allItems
        : [];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('服务预约', style: AppTextStyles.headlineSmall),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSegmentedTabs(ref, activeTab),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: filteredItems.isEmpty
                ? const AppEmpty(message: '暂无数据')
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _ServiceCard(item: item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs(WidgetRef ref, String activeTab) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final key = _statusKeys[i];
            final isActive = activeTab == key;
            return GestureDetector(
              onTap: () => ref.read(serviceTabProvider.notifier).setTab(key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  _tabs[i],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final dynamic item;
  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 96,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4D4D4),
                foregroundColor: AppColors.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                minimumSize: const Size.fromHeight(36),
              ),
              child: const Text(
                '去预约',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


