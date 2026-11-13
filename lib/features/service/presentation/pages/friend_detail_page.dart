import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/auth_redirect.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/offline_activity_detail_model.dart';
import '../providers/offline_activity_detail_provider.dart';
import '../widgets/project_detail_hero_image.dart';
import '../widgets/friend_detail_info_card.dart';
import '../pages/service_friend_booking_form_page.dart';

/// 挚友报名会详情页面（挚友会 tab - 真实 API 数据）
///
/// 路由: /service/friend/:id
/// 进入方式: 从服务中心 - 挚友报名会 tab 列表页跳转
/// 数据源: getofflineactivitydetail 接口，activityid 由列表页传入
class FriendDetailPage extends ConsumerWidget {
  final String activityId;

  const FriendDetailPage({super.key, required this.activityId});

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
        data: (detail) => _buildBody(detail),
      ),
      bottomNavigationBar: detailAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
        data: (detail) => _buildBottomBar(context, ref, detail),
      ),
    );
  }

  Future<void> _onBookTap(BuildContext context, WidgetRef ref, OfflineActivityDetail detail) async {
    if (!detail.isSignup) return;

    // 检查登录状态
    final session = ref.read(sessionProvider.notifier);
    await session.ensureInitialized();
    final isLoggedIn = ref.read(sessionProvider) == SessionState.authenticated;

    if (!context.mounted) return;

    if (!isLoggedIn) {
      // 未登录：跳转登录页，登录后返回当前页面
      final returnTo = GoRouterState.of(context).uri.toString();
      GoRouter.of(context).push(loginLocationFor(returnTo));
      return;
    }

    // 已登录：跳转报名表单页
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceFriendBookingFormPage(detail: detail)));
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, OfflineActivityDetail detail) {
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
            onTap: detail.isSignup ? () => _onBookTap(context, ref, detail) : null,
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

  Widget _buildBody(OfflineActivityDetail detail) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ProjectDetailHeroImage(heroAsset: detail.postUrl, horizontalPadding: AppSpacing.lg, aspectRatio: 412 / 180),
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: FriendDetailInfoCard(detail: detail),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
        onPressed: () => context.pop(),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
      title: Text('挚友报名会', style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black)),
      centerTitle: false,
    );
  }
}
