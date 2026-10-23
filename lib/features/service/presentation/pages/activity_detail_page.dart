import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../domain/models/service_project_detail_model.dart';
import '../providers/service_project_detail_provider.dart';
import '../widgets/activity_detail_info_card.dart';
import '../widgets/project_detail_hero_image.dart';
import '../widgets/project_detail_bottom_bar.dart';

/// 活动详情页面（活动 tab - Mock 数据）
///
/// 路由: /service/activity/:id
/// 进入方式: 从服务中心 - 活动 tab 列表页跳转
class ActivityDetailPage extends ConsumerWidget {
  final String projectId;

  const ActivityDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(serviceProjectDetailProvider(projectId));

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: projectAsync.when(
        loading: () => _buildAppBar(context),
        error: (_, _) => _buildAppBar(context),
        data: (activity) => _buildAppBar(context, title: activity.title),
      ),
      body: projectAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => Center(
          child: AppError(message: '加载失败，请稍后重试', onRetry: () => ref.invalidate(serviceProjectDetailProvider(projectId))),
        ),
        data: (activity) => _buildBody(activity),
      ),
      bottomNavigationBar: projectAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
        data: (activity) => ProjectDetailBottomBar(product: activity),
      ),
    );
  }

  Widget _buildBody(ServiceProjectDetail activity) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 13, bottom: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final heroHeight = (constraints.maxWidth - 28) * 180 / 412;
                final overlap = heroHeight * 50 / 180;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ProjectDetailHeroImage(heroAsset: activity.heroAsset, horizontalPadding: 14, aspectRatio: 412 / 180),
                    Padding(
                      padding: EdgeInsets.only(top: heroHeight - overlap),
                      child: ActivityDetailInfoCard(activity: activity),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, {String? title}) {
    return AppBar(
      backgroundColor: AppColors.servicePageBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 52,
      leading: IconButton(
        padding: const EdgeInsets.only(left: 14, right: 14),
        icon: Image.asset('assets/images/service/activity_detail_back.png', width: 24, height: 24),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(title ?? '活动详情', style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black)),
      centerTitle: false,
    );
  }
}
