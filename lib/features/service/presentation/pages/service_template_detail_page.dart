import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/models/share_cart_template_model.dart';
import '../providers/service_provider.dart';

/// 购酒享服务模板详情页面
///
/// 路由: /service/template/:id
/// 进入方式: 从服务中心「购酒享服务」列表页点击跳转
///
/// 页面结构（蓝湖设计稿还原）：
///   - AppBar：返回图标 + 动态标题（来自模板名称）
///   - Banner：网络图片，230dp 高，底部圆角 12dp
///   - 白色信息卡片：大标题 + 蓝色渐变指示条 + 描述文字 + 底部配图
///   - 底部固定栏：渐变胶囊按钮「立即加购」
class ServiceTemplateDetailPage extends ConsumerWidget {
  final int templateId;

  const ServiceTemplateDetailPage({super.key, required this.templateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateAsync = ref.watch(shareCartTemplateProvider);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: _buildAppBar(context, templateAsync),
      body: templateAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (_, __) => Center(
          child: AppError(
            message: '加载失败，请稍后重试',
            onRetry: () => ref.invalidate(shareCartTemplateProvider),
          ),
        ),
        data: (templates) {
          // 优先按 ID 查找，找不到时回退到第一条数据
          final template = templates.isNotEmpty
              ? templates.firstWhere(
                  (t) => t.templateId == templateId,
                  orElse: () => templates.first,
                )
              : ShareCartTemplate(
                  templateId: templateId,
                  templateName: '',
                  headImg: '',
                  requirements: '',
                );
          return _buildBody(template, bottomInset);
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// AppBar：动态标题取自模板名称，返回按钮使用设计稿 PNG 图标
  PreferredSizeWidget _buildAppBar(BuildContext context, AsyncValue<List<ShareCartTemplate>> asyncValue) {
    String title = '服务详情';
    final found = asyncValue.maybeWhen(
      data: (templates) {
        if (templates.isEmpty) return null;
        return templates.firstWhere(
          (t) => t.templateId == templateId,
          orElse: () => templates.first,
        );
      },
      orElse: () => null,
    );
    if (found != null && found.templateName.isNotEmpty) {
      title = found.templateName.length > 12
          ? '${found.templateName.substring(0, 12)}…'
          : found.templateName;
    }
    return AppBar(
      backgroundColor: AppColors.servicePageBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      centerTitle: false,
    );
  }

  /// 主体内容：Banner + 白色信息卡片，使用 CustomScrollView 滚动
  Widget _buildBody(ShareCartTemplate template, double bottomInset) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── Section A: Banner ──
        SliverToBoxAdapter(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.md)),
            child: AppNetworkImage(
              url: template.headImg,
              height: 230,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // ── Section B: 白色信息卡片 ──
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
          sliver: SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 107),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 大标题 "服务简介"
                  const Text(
                    '服务简介',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  //const SizedBox(height: 18),
                  // 蓝色渐变指示条 94×7
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Container(
                      width: 94,
                      height: 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.round),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [AppColors.serviceProjectBlue, Color(0x00F3F5F7)],
                        ),
                    ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 描述文字（左缩进 10dp，模拟设计稿空格效果）
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      template.requirements.isNotEmpty ? template.requirements : '暂未填写服务说明',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 底部配图（394×368，设计稿重要元素）
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: AppNetworkImage(
                      url: template.headImg.isNotEmpty ? template.headImg : 'assets/images/service/service_goujiu.webp',
                      height: 368,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // 底部留白，确保最后一项内容不被底部栏遮挡
        SliverToBoxAdapter(
          child: SizedBox(height: 88 + bottomInset),
        ),
      ],
    );
  }

  /// 底部固定操作栏：白色背景 + 向上阴影 + 渐变胶囊按钮
  Widget _buildBottomBar(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final btnWidth = screenWidth - AppSpacing.xxxl; // 左右各 30dp

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
        ),
        child: Center(
          child: Container(
            width: btnWidth,
            height: 51,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.round),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.serviceCtaGradStart, AppColors.serviceTabActive],
              ),
            ),
            child: const Center(
              child: Text(
                '立即加购',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
