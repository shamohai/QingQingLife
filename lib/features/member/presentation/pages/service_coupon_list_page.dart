import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/coupon_group_model.dart';
import '../../data/models/service_coupon_model.dart';
import '../providers/service_coupon_list_provider.dart';
import '../widgets/coupon_group_card.dart';
import '../widgets/service_coupon_action_sheet.dart';
import '../widgets/service_coupon_transfer_dialog.dart';

/// 天佑德服务券列表页（/coupons/service）
class ServiceCouponListPage extends ConsumerStatefulWidget {
  const ServiceCouponListPage({super.key});

  @override
  ConsumerState<ServiceCouponListPage> createState() => _ServiceCouponListPageState();
}

class _ServiceCouponListPageState extends ConsumerState<ServiceCouponListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceCouponListProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceCouponListProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.white),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Image.asset('assets/images/member/about_lake_bg.png', width: double.infinity, fit: BoxFit.fitWidth),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildNavBar(context),
                  _buildTabs(state),
                  Expanded(
                    child: RefreshIndicator(onRefresh: () => ref.read(serviceCouponListProvider.notifier).load(), child: _buildContent(state)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.only(left: AppSpacing.md),
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF000000)),
            ),
          ),
          const Text(
            '天佑德服务券',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF000000), height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(ServiceCouponListState state) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          for (final status in ServiceCouponStatus.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ref.read(serviceCouponListProvider.notifier).selectStatus(status),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: status == state.status ? FontWeight.w600 : FontWeight.w400,
                        color: status == state.status ? const Color(0xFF173A70) : const Color(0xFF1A1D1C),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(width: 30, height: 3, color: status == state.status ? const Color(0xFF1F4E8C) : Colors.transparent),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(ServiceCouponListState state) {
    if (state.loading && state.coupons.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 300, child: AppLoading())],
      );
    }

    if (state.errorMessage != null && state.coupons.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 320,
            child: AppError(message: state.errorMessage!, onRetry: () => ref.read(serviceCouponListProvider.notifier).load()),
          ),
        ],
      );
    }

    if (state.coupons.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 320,
            child: AppEmpty(message: '暂无${state.status.label}服务券', icon: Icons.card_membership_outlined),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl),
      itemCount: state.coupons.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final coupon = state.coupons[index];
        return CouponGroupCard(
          coupon: _toCardData(coupon),
          typeLabel: '服务券',
          statusOverride: _toCardStatus(state.status),
          actionLabelOverride: state.status == ServiceCouponStatus.valid ? null : state.status.label,
          onTap: () => _onCouponTap(context, coupon, state.status),
        );
      },
    );
  }

  static CouponGroupStatus _toCardStatus(ServiceCouponStatus status) {
    return switch (status) {
      ServiceCouponStatus.valid => CouponGroupStatus.valid,
      ServiceCouponStatus.invalid => CouponGroupStatus.expired,
      ServiceCouponStatus.transferring => CouponGroupStatus.transferring,
    };
  }

  static CouponGroupInfo _toCardData(ServiceCouponInfo coupon) {
    return CouponGroupInfo(
      couponName: coupon.couponName,
      money: coupon.money,
      limitLowAmount: Decimal.zero,
      endTime: coupon.endTime,
      status: _toCardStatus(coupon.status),
      available: coupon.status == ServiceCouponStatus.valid,
      count: coupon.num,
      canTransfer: coupon.canTransfer,
    );
  }

  Future<void> _onCouponTap(BuildContext context, ServiceCouponInfo coupon, ServiceCouponStatus status) async {
    if (status != ServiceCouponStatus.valid) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ServiceCouponActionSheet(couponName: coupon.couponName, canDeliver: coupon.canDeliver, canTransfer: coupon.canTransfer),
    );
    if (!context.mounted || action == null) return;

    if (action == '到店使用') {
      final refreshed = await context.push<bool>(RouteNames.serviceCouponUse, extra: coupon);
      if (!mounted || refreshed != true) return;
      await ref.read(serviceCouponListProvider.notifier).load();
      return;
    }

    if (action == '转增好友') {
      await runServiceCouponTransferFlow(context: context, ref: ref, coupon: coupon);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$action功能待接入'), behavior: SnackBarBehavior.floating));
  }
}
