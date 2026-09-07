import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';
import '../widgets/service_entry_card.dart';

/// 服务预约主入口页面
///
/// 展示三类功能卡片，每项右侧配有操作按钮，点击后跳转到 [ServiceRecordsPage] 并传入对应 Tab。
class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          '服务预约',
          style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push(RouteNames.serviceRecords),
            child: const Text(
              '预约/报名记录',
              style: TextStyle(fontSize: 14, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: _buildCardList(),
      ),
    );
  }

  /// 三张功能入口卡片
  Widget _buildCardList() {
    final items = [
      ServiceEntryCard(title: '场馆预约', buttonText: '去预约', listMode: 'ongoing'),
      ServiceEntryCard(title: '活动报名', buttonText: '去报名', listMode: 'upcoming'),
      ServiceEntryCard(title: '高端挚友会+', buttonText: '去参加', listMode: 'ongoing'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => items[index],
    );
  }
}
