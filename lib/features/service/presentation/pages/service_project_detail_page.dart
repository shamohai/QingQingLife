import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../domain/models/service_project_detail_model.dart';
import '../providers/service_project_detail_provider.dart';
import '../widgets/project_detail_bottom_bar.dart';
import '../widgets/project_detail_header.dart';
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
      body: Stack(
        children: [
          // 滚动内容层
          projectAsync.when(
            loading: () => const Center(child: AppLoading()),
            error: (error, stack) => Center(
              child: AppError(
                message: '加载失败，请稍后重试',
                onRetry: () => ref.invalidate(serviceProjectDetailProvider(projectId)),
              ),
            ),
            data: (product) => _buildBody(product),
          ),
          // 固定底部操作栏（不随内容滚动）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              bottom: true,
              child: projectAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (product) => ProjectDetailBottomBar(product: product),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ServiceProjectDetail product) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 0)),
        SliverToBoxAdapter(
          child: ProjectDetailHeader(product: product),
        ),
        // Hero 图 + InfoCard 层叠：InfoCard 覆盖在 Hero 底部向上 20px，四角圆角
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ProjectDetailHeroImage(heroAsset: product.heroAsset),
              Positioned(
                left: 0,
                right: 0,
                top: 222, // HeroImage 高度 242 - paddingBottom 49 + marginTop 13 = 206? 实测 222 约为图片底部
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: ProjectDetailInfoCard(product: product),
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 88), // 底部操作栏留空
        ),
      ],
    );
  }
}
