import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../app/theme/app_radius.dart';
import '../../domain/models/offline_activity_detail_model.dart';
import '../providers/offline_activity_detail_provider.dart';
import '../widgets/activity_detail_info_card.dart';
import '../widgets/project_detail_hero_image.dart';
import '../pages/service_activity_booking_form_page.dart';

/// 活动详情页面（活动报名 tab - 真实 API 数据）
///
/// 路由: /service/activity/:id
/// 进入方式: 从服务中心 - 活动报名 tab 列表页跳转
/// 数据源: getofflineactivitydetail 接口，activityid 由列表页传入
class ActivityDetailPage extends ConsumerWidget {
  final String activityId;

  const ActivityDetailPage({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(offlineActivityDetailProvider(activityId));

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: detailAsync.when(
        loading: () => _buildAppBar(context),
        error: (_, _) => _buildAppBar(context),
        data: (detail) => _buildAppBar(context, title: detail.title),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (_, _) => Center(
          child: AppError(message: '加载失败，请稍后重试', onRetry: () => ref.invalidate(offlineActivityDetailProvider(activityId))),
        ),
        data: (detail) => _buildBody(context, detail),
      ),
      bottomNavigationBar: detailAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
        data: (detail) => _buildBottomBar(context, detail),
      ),
    );
  }

  void _onBookTap(BuildContext context, OfflineActivityDetail detail) {
    if (!detail.isSignup) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceActivityBookingFormPage(detail: detail)));
  }

  /// 底部固定操作栏：已报名时按钮置灰显示"已报名"，可点击时跳转报名表单
  Widget _buildBottomBar(BuildContext context, OfflineActivityDetail detail) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final btnWidth = screenWidth - 60;

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Center(
          child: GestureDetector(
            onTap: detail.isSignup ? () => _onBookTap(context, detail) : null,
            child: Container(
              width: btnWidth,
              height: 51,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.round),
                gradient: detail.isSignup
                    ? const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [AppColors.serviceCtaGradStart, AppColors.serviceTabActive],
                      )
                    : null,
                color: detail.isSignup ? null : const Color(0xFFCCCCCC),
              ),
              child: Center(
                child: Text(
                  detail.isSignup ? '立即报名' : detail.message,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white, height: 1.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OfflineActivityDetail detail) {
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
                    ProjectDetailHeroImage(heroAsset: detail.postUrl, horizontalPadding: 14, aspectRatio: 412 / 180),
                    Padding(
                      padding: EdgeInsets.only(top: heroHeight - overlap),
                      child: ActivityDetailInfoCard(detail: detail),
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
        icon: Image.asset(
          'assets/images/service/activity_detail_back.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.arrow_back, color: Colors.black, size: 24),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('活动详情', style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black)),
      centerTitle: false,
    );
  }
}
