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
      body: Column(
        children: [
          // 顶部留白：状态栏高度 + 额外间距，避免标题被状态栏遮挡
          SizedBox(height: MediaQuery.of(context).padding.top + AppSpacing.lg),
          _buildAppBar(context),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: _buildCardList(),
          ),
        ],
      ),
    );
  }

  /// 自定义 App Bar：标题居中 + 右上角记录链接
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          const Spacer(),
          Text(
            '服务预约',
            style: AppTextStyles.headlineSmall,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              context.push(RouteNames.serviceRecords);
            },
            child: Text(
              '预约/报名记录',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
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
