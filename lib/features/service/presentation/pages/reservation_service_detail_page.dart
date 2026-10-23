import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/reservation_service_detail_model.dart';
import '../providers/reservation_service_detail_provider.dart';
import '../widgets/project_detail_hero_image.dart';
import '../widgets/reservation_service_detail_info_card.dart';
import '../widgets/reservation_service_detail_bottom_bar.dart';

/// 预约服务详情页面（服务预约 tab - 真实 API 数据）
///
/// 路由: /service/reservation/:id
/// 进入方式: 从服务中心 - 服务预约 tab 列表页跳转
class ReservationServiceDetailPage extends ConsumerWidget {
  final String serviceId;

  const ReservationServiceDetailPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(serviceId) ?? 0;
    final detailAsync = ref.watch(reservationServiceDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: detailAsync.when(
        loading: () => _buildAppBar(context),
        error: (_, _) => _buildAppBar(context),
        data: (detail) => _buildAppBar(context, detail: detail),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => Center(
          child: AppError(message: '加载失败，请稍后重试', onRetry: () => ref.invalidate(reservationServiceDetailProvider(id))),
        ),
        data: (detail) => _buildBody(detail),
      ),
      bottomNavigationBar: detailAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
        data: (detail) => ReservationServiceDetailBottomBar(detail: detail),
      ),
    );
  }

  Widget _buildBody(ReservationServiceDetail detail) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ProjectDetailHeroImage(heroAsset: detail.headImgUrl, horizontalPadding: AppSpacing.lg, aspectRatio: 412 / 180),
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: ReservationServiceDetailInfoCard(detail: detail),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, {ReservationServiceDetail? detail}) {
    final remark = detail?.reservationRemark ?? '';
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
      title: Text(detail?.serviceName ?? '预约项目详情', style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black)),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: TextButton(
            onPressed: remark.isNotEmpty ? () => _showReservationRemarkDialog(context, remark) : null,
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(
              '预约说明',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: remark.isNotEmpty ? AppColors.serviceProjectBlue : AppColors.serviceProjectBlue.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showReservationRemarkDialog(BuildContext context, String remark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('预约说明', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Text(remark, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF333333), height: 1.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('知道了', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.serviceTabActive)),
          ),
        ],
      ),
    );
  }
}
