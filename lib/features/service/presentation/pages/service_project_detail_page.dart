import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../domain/models/service_project_detail_model.dart';
import '../providers/service_project_detail_provider.dart';
import '../widgets/activity_detail_info_card.dart';
import '../widgets/friend_detail_info_card.dart';
import '../widgets/project_detail_bottom_bar.dart';
import '../widgets/project_detail_hero_image.dart';
import '../widgets/project_detail_info_card.dart';

/// 预约项目详情页面
///
/// 路由: /service/project/:id
/// 进入方式: 从服务中心列表页跳转
class ServiceProjectDetailPage extends ConsumerWidget {
  final String projectId;

  const ServiceProjectDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(serviceProjectDetailProvider(projectId));

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: projectAsync.when(
        loading: () => _buildAppBar(context),
        error: (_, _) => _buildAppBar(context),
        data: (product) => _buildAppBar(
          context,
          title: product.title,
          isActivity: product.type == ServiceProjectDetailType.activity,
          isFriend: product.type == ServiceProjectDetailType.friend,
        ),
      ),
      body: projectAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => Center(
          child: AppError(message: '加载失败，请稍后重试', onRetry: () => ref.invalidate(serviceProjectDetailProvider(projectId))),
        ),
        data: (product) => _buildBody(product),
      ),
      bottomNavigationBar: projectAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
        data: (product) => ProjectDetailBottomBar(product: product),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, {String? title, bool isActivity = false, bool isFriend = false}) {
    final pageTitle = isActivity ? '活动详情' : (isFriend ? '挚友报名会' : '预约项目详情');
    return AppBar(
      backgroundColor: AppColors.servicePageBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 52,
      leading: IconButton(
        padding: const EdgeInsets.only(left: 14, right: 14),
        icon: isActivity
            ? Image.asset('assets/images/service/activity_detail_back.png', width: 24, height: 24)
            : const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(pageTitle, style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black)),
      centerTitle: false,
      actions: [
        if (!isActivity)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: TextButton(
              onPressed: () => context.push(RouteNames.customerService),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text(
                '预约说明',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.serviceProjectBlue),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(ServiceProjectDetail product) {
    if (product.type == ServiceProjectDetailType.activity) {
      return _buildActivityBody(product);
    }
    if (product.type == ServiceProjectDetailType.friend) {
      return _buildFriendBody(product);
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ProjectDetailHeroImage(heroAsset: product.heroAsset, horizontalPadding: 14, aspectRatio: 412 / 180),
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: ProjectDetailInfoCard(product: product),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendBody(ServiceProjectDetail product) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ProjectDetailHeroImage(heroAsset: product.heroAsset, horizontalPadding: 14, aspectRatio: 412 / 180),
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: FriendDetailInfoCard(project: product),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityBody(ServiceProjectDetail activity) {
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
}
