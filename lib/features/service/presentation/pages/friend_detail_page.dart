import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/service_project_detail_model.dart';
import '../providers/service_project_detail_provider.dart';
import '../widgets/project_detail_hero_image.dart';
import '../widgets/friend_detail_info_card.dart';
import '../widgets/project_detail_bottom_bar.dart';

/// 挚友报名会详情页面（挚友会 tab - Mock 数据）
///
/// 路由: /service/friend/:id
/// 进入方式: 从服务中心 - 挚友报名会 tab 列表页跳转
class FriendDetailPage extends ConsumerWidget {
  final String projectId;

  const FriendDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(serviceProjectDetailProvider(projectId));

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: projectAsync.when(
        loading: () => _buildAppBar(context),
        error: (_, _) => _buildAppBar(context),
        data: (product) => _buildAppBar(context, title: product.title),
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

  Widget _buildBody(ServiceProjectDetail product) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ProjectDetailHeroImage(heroAsset: product.heroAsset, horizontalPadding: AppSpacing.lg, aspectRatio: 412 / 180),
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

  PreferredSizeWidget _buildAppBar(BuildContext context, {String? title}) {
    return AppBar(
      backgroundColor: AppColors.servicePageBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 52,
      leading: IconButton(
        padding: const EdgeInsets.only(left: 14, right: 14),
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(title ?? '挚友报名会', style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black)),
      centerTitle: false,
    );
  }
}
