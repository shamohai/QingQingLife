import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../domain/models/service_project_detail_model.dart';
import '../providers/service_project_detail_provider.dart';
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
        error: (_, __) => _buildAppBar(context),
        data: (product) => _buildAppBar(context, title: '预约项目详情'),
      ),
      body: projectAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => Center(
          child: AppError(
            message: '加载失败，请稍后重试',
            onRetry: () => ref.invalidate(serviceProjectDetailProvider(projectId)),
          ),
        ),
        data: (product) => _buildBody(product),
      ),
      bottomNavigationBar: projectAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (product) => SafeArea(
          top: false,
          bottom: true,
          child: ProjectDetailBottomBar(product: product),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, {String? title}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title ?? '预约项目详情',
        style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black),
      ),
      centerTitle: false,
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
                ProjectDetailHeroImage(heroAsset: product.heroAsset),
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
}
