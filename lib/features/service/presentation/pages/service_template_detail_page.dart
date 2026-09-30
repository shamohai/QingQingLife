import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../domain/models/share_cart_template_model.dart';
import '../providers/service_provider.dart';

/// 购酒享服务模板详情页面
///
/// 路由: /service/template/:id
/// 进入方式: 从服务中心「购酒享服务」列表页点击跳转
class ServiceTemplateDetailPage extends ConsumerWidget {
  final int templateId;

  const ServiceTemplateDetailPage({super.key, required this.templateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateAsync = ref.watch(shareCartTemplateProvider);

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.servicePageBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('模板详情', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: templateAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => Center(
          child: AppError(
            message: '加载失败，请稍后重试',
            onRetry: () => ref.invalidate(shareCartTemplateProvider),
          ),
        ),
        data: (templates) {
          final template = templates.firstWhere(
            (t) => t.templateId == templateId,
            orElse: () => templates.first,
          );
          return _buildBody(template);
        },
      ),
    );
  }

  Widget _buildBody(ShareCartTemplate template) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // 头图
        SliverToBoxAdapter(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: _buildNetworkImage(template.headImg, height: 200),
          ),
        ),
        // 内容区
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 模板名称
                Text(
                  template.templateName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                ),
                const SizedBox(height: 16),
                // 要求说明（如有内容）
                if (template.requirements.isNotEmpty) ...[
                  const Text(
                    '要求说明',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      template.requirements,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImage(String url, {double height = 200}) {
    if (url.isEmpty) {
      return Container(height: height, color: AppColors.surfaceVariant);
    }
    return Image.network(
      url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.image_outlined, size: 48, color: AppColors.outline),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: height,
          color: AppColors.surfaceVariant,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
