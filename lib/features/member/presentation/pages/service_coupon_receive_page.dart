import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../providers/service_coupon_receive_provider.dart';

/// 好友转赠服务券领取页（/coupons/service/receive）。
class ServiceCouponReceivePage extends ConsumerWidget {
  const ServiceCouponReceivePage({
    super.key,
    required this.shareGroupId,
    required this.serviceCouponId,
    required this.couponName,
    this.endTime,
    this.count = 1,
  });

  final String shareGroupId;
  final int serviceCouponId;
  final String couponName;
  final DateTime? endTime;
  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (shareGroupId: shareGroupId, serviceCouponId: serviceCouponId);
    final state = ref.watch(serviceCouponReceiveProvider(args));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF003680),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF003680), Color(0xFF327EE5)]),
          ),
          child: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildNavBar(context),
                    Expanded(
                      child: shareGroupId.trim().isEmpty
                          ? _buildInvalidContent(context)
                          : SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 186 + MediaQuery.viewPaddingOf(context).bottom),
                              child: Column(
                                children: [
                                  _buildBrand(),
                                  const SizedBox(height: 18),
                                  _buildCouponCard(),
                                  const SizedBox(height: AppSpacing.lg),
                                  _buildUsageCard(),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              if (shareGroupId.trim().isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 68 + MediaQuery.viewPaddingOf(context).bottom,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/service/mountain.png',
                      width: double.infinity,
                      height: 118,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              if (shareGroupId.trim().isNotEmpty)
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: _ReceiveButton(
                      state: state,
                      onTap: () {
                        if (state.received) {
                          context.go(RouteNames.serviceCouponList);
                          return;
                        }
                        _handleReceive(context, ref, args);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return AppPageHeader(
      left: InkResponse(
        onTap: () => context.go(RouteNames.home),
        radius: 22,
        child: const SizedBox(
          width: 37,
          height: 44,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Icon(Icons.home_outlined, size: 21, color: Colors.white),
          ),
        ),
      ),
      center: const Text(
        '卡券领取',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white, height: 1.2),
      ),
    );
  }

  Widget _buildBrand() {
    return SizedBox(
      height: 92,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '天佑德  青稞酒',
            maxLines: 1,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              fontFamily: 'STKaiti',
              fontFamilyFallback: const ['serif'],
              color: Colors.white,
              height: 1.1,
              shadows: [Shadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 2, offset: const Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCouponCard() {
    final displayName = _displayCouponName(couponName);
    final validity = _displayValidity(endTime);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFF3DD), Color(0xFFFFE6C8)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1D6A5), width: 1),
      ),
      child: Container(
        height: 158,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 13),
          child: Column(
            children: [
              Text(
                count > 1 ? '你的好友赠送了你$count张' : '你的好友赠送了你一张',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF303030), height: 1.2),
              ),
              const SizedBox(height: 9),
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      displayName,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1B2F63), height: 1.1),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '请尽快领取哦！',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFE25517), height: 1.2),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '领取有效期：$validity',
                        maxLines: 1,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w400, color: Color(0xFF8A5A32), height: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '使用说明',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C), height: 1.2),
          ),
          SizedBox(height: 12),
          Text(
            '青轻生活APP — 点击“我的”—打开“卡包”—打开“天佑德服务券”—选择需要使用的服务券—根据引导提示使用',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF4A4A4A), height: 1.75),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidContent(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.xl),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_off, size: 42, color: Color(0xFF8A8A8A)),
            const SizedBox(height: AppSpacing.md),
            const Text(
              '分享链接无效',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C)),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text('请让好友重新分享服务券', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: FilledButton(
                onPressed: () => context.go(RouteNames.home),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF284BBA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
                ),
                child: const Text('返回首页'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleReceive(BuildContext context, WidgetRef ref, ServiceCouponReceiveArgs args) async {
    final notifier = ref.read(serviceCouponReceiveProvider(args).notifier);
    final success = await notifier.receive();
    if (!context.mounted) return;

    final message = success ? '领取成功，已放入我的服务券' : (ref.read(serviceCouponReceiveProvider(args)).errorMessage ?? '领取失败，请稍后重试');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  static String _displayCouponName(String name) {
    final value = name.trim();
    if (value.isEmpty) return '【金牌服务券】';
    if (value.startsWith('【') || value.startsWith('[')) return value;
    return '【$value】';
  }

  static String _displayValidity(DateTime? date) {
    if (date == null) return '以实际领取结果为准';
    final localDate = date.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${localDate.year}-${two(localDate.month)}-${two(localDate.day)} ${two(localDate.hour)}:${two(localDate.minute)}:${two(localDate.second)}';
  }
}

class _ReceiveButton extends StatelessWidget {
  const _ReceiveButton({required this.state, required this.onTap});

  final ServiceCouponReceiveState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = state.received ? '查看我的服务券' : (state.submitting ? '领取中...' : '立即收下');
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF213775), Color(0xFF3152AF)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFF162D74).withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 5))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: state.submitting ? null : onTap,
            child: Center(
              child: state.submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      label,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
