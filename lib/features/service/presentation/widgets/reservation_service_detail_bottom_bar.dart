import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/auth_redirect.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/providers/session_provider.dart';
import '../../domain/models/reservation_service_detail_model.dart';

/// 预约服务详情 — 底部固定操作栏（服务预约 tab 真实 API 数据）
///
/// 固定高度 80dp，白色背景，顶部阴影。
/// - myReservationInfo 为 null：显示「立即预约」渐变按钮，可点击跳转报名页
/// - myReservationInfo 不为 null：显示「已预约」灰色按钮，不可点击
class ReservationServiceDetailBottomBar extends ConsumerWidget {
  final ReservationServiceDetail detail;

  const ReservationServiceDetailBottomBar({super.key, required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final btnWidth = screenWidth - 60;
    final hasReserved = detail.myReservationInfo != null;

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
            onTap: hasReserved ? null : () => _handleBookTap(context, ref),
            child: Container(
              width: btnWidth,
              height: 51,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.round),
                gradient: hasReserved
                    ? null
                    : const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [AppColors.serviceCtaGradStart, AppColors.serviceTabActive],
                      ),
                color: hasReserved ? AppColors.serviceButtonDisabled : null,
              ),
              child: Center(
                child: Text(
                  hasReserved ? '已预约' : '立即预约',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: hasReserved ? AppColors.serviceButtonDisabledText : Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBookTap(BuildContext context, WidgetRef ref) async {
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

    // 已登录：跳转预约表单页
    if (!context.mounted) return;
    context.pushNamed(
      'serviceBookingForm',
      pathParameters: {'id': detail.serviceId.toString()},
      extra: detail, // 传递完整的 detail 对象
    );
  }
}
