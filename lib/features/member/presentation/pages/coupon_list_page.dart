import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/coupon_group_model.dart';
import '../providers/coupon_list_provider.dart';
import '../widgets/coupon_group_card.dart';

/// 天佑德优惠券列表页（/coupons/list）
class CouponListPage extends ConsumerStatefulWidget {
  const CouponListPage({super.key});

  @override
  ConsumerState<CouponListPage> createState() => _CouponListPageState();
}

class _CouponListPageState extends ConsumerState<CouponListPage> {
  static const _visibleStatuses = [CouponGroupStatus.valid, CouponGroupStatus.used, CouponGroupStatus.expired];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(couponListProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(couponListProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: _buildBackground()),
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
                    child: RefreshIndicator(onRefresh: () => ref.read(couponListProvider.notifier).load(), child: _buildContent(state)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return const ColoredBox(color: Colors.white);
  }

  Widget _buildNavBar(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF000000), size: 22),
            onPressed: () => context.pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          const Text(
            '天佑德优惠券',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF000000), height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(CouponListState state) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          for (final status in _visibleStatuses)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ref.read(couponListProvider.notifier).selectStatus(status),
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

  Widget _buildContent(CouponListState state) {
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
            child: AppError(message: state.errorMessage!, onRetry: () => ref.read(couponListProvider.notifier).load()),
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
            child: AppEmpty(message: '暂无${state.status.label}优惠券', icon: Icons.confirmation_num_outlined),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxxl),
      itemCount: state.coupons.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final coupon = state.coupons[index];
        return CouponGroupCard(coupon: coupon, statusOverride: state.status);
      },
    );
  }
}
