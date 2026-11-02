import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/cash_coupon_model.dart';
import '../providers/locked_red_packet_provider.dart';
import '../widgets/coupon_group_card.dart';
import '../widgets/locked_red_packet_detail_sheet.dart';

/// 待解锁红包列表页（/coupons/red-packet）。
class LockedRedPacketListPage extends ConsumerStatefulWidget {
  const LockedRedPacketListPage({super.key});

  @override
  ConsumerState<LockedRedPacketListPage> createState() => _LockedRedPacketListPageState();
}

class _LockedRedPacketListPageState extends ConsumerState<LockedRedPacketListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lockedRedPacketListProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lockedRedPacketListProvider);

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
                    child: RefreshIndicator(onRefresh: () => ref.read(lockedRedPacketListProvider.notifier).load(), child: _buildContent(state)),
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
            '待解锁红包',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF000000), height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(LockedRedPacketListState state) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          for (final status in CashCouponStatus.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ref.read(lockedRedPacketListProvider.notifier).selectStatus(status),
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

  Widget _buildContent(LockedRedPacketListState state) {
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
            child: AppError(message: state.errorMessage!, onRetry: () => ref.read(lockedRedPacketListProvider.notifier).load()),
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
            child: AppEmpty(message: '暂无${state.status.label}红包', icon: Icons.card_giftcard),
          ),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 240) {
          ref.read(lockedRedPacketListProvider.notifier).loadMore();
        }
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxxl),
        itemCount: state.coupons.length + (state.hasMore || state.loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == state.coupons.length) return _buildFooter(state);

          final coupon = state.coupons[index];
          final card = coupon.toCardModel();
          return CouponGroupCard(coupon: card, typeLabel: '待解锁', statusOverride: card.status, onTap: () => _showDetail(context, coupon));
        },
      ),
    );
  }

  Widget _buildFooter(LockedRedPacketListState state) {
    if (state.errorMessage != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(lockedRedPacketListProvider.notifier).loadMore(),
        child: const SizedBox(
          height: 52,
          child: Center(
            child: Text('加载失败，点击重试', style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
          ),
        ),
      );
    }

    return const SizedBox(
      height: 52,
      child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
    );
  }

  void _showDetail(BuildContext context, CashCouponInfo coupon) {
    if (coupon.couponSn.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('红包信息无效，请刷新后重试'), behavior: SnackBarBehavior.floating));
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => LockedRedPacketDetailSheet(couponSn: coupon.couponSn),
    );
  }
}
