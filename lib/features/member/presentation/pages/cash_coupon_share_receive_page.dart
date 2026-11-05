import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../providers/cash_coupon_share_provider.dart';

/// 好友分享的待解锁红包领取页。
class CashCouponShareReceivePage extends ConsumerStatefulWidget {
  const CashCouponShareReceivePage({super.key, required this.shareCode});

  final String shareCode;

  @override
  ConsumerState<CashCouponShareReceivePage> createState() => _CashCouponShareReceivePageState();
}

class _CashCouponShareReceivePageState extends ConsumerState<CashCouponShareReceivePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(cashCouponShareReceiveProvider(widget.shareCode).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashCouponShareReceiveProvider(widget.shareCode));
    final result = state.result;
    final config = result?.configInfo;
    final hasShareCode = widget.shareCode.trim().isNotEmpty;
    final canClaim = hasShareCode && state.loaded && result?.canReceive == true && config != null && !state.received;
    final showUnavailableReason = result != null && !result.canReceive && !state.received;
    final unavailableReason = result?.reason.trim().isNotEmpty == true ? result!.reason.trim() : '当前红包暂不可领取';
    final showAdditionalError = state.errorMessage != null && result != null && (!showUnavailableReason || state.errorMessage!.trim() != unavailableReason);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D3977),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0D3977), Color(0xFF3983CC)]),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildNavBar(context),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => ref.read(cashCouponShareReceiveProvider(widget.shareCode).notifier).load(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(AppSpacing.lg, 10, AppSpacing.lg, 20 + MediaQuery.viewPaddingOf(context).bottom),
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          '青轻生活',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2),
                        ),
                        const SizedBox(height: 22),
                        if (!hasShareCode)
                          _buildMessagePanel(icon: Icons.link_off, title: '分享链接无效', message: '请让好友重新分享红包')
                        else if (!state.loaded && result == null)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: Center(child: CircularProgressIndicator(color: Colors.white)),
                          )
                        else if (state.errorMessage != null && result == null)
                          _buildMessagePanel(icon: Icons.error_outline, title: '红包信息加载失败', message: state.errorMessage!)
                        else if (result != null && config != null) ...[
                          _buildCouponCard(config.couponName, config.money.toStringAsFixed(2), result.fromUserName, result.shareExpireTime),
                          const SizedBox(height: AppSpacing.lg),
                          _buildDetails(
                            config.productName,
                            config.rebate.toStringAsFixed(2),
                            config.startTime,
                            config.endTime,
                            config.remark,
                            result.activityDescriptionHtml,
                          ),
                          if (showUnavailableReason) ...[const SizedBox(height: AppSpacing.md), _buildReason(unavailableReason)],
                        ] else if (result != null)
                          _buildMessagePanel(icon: Icons.error_outline, title: '红包信息不完整', message: '请让好友重新分享红包'),
                        if (showAdditionalError) ...[const SizedBox(height: AppSpacing.md), _buildReason(state.errorMessage!)],
                      ],
                    ),
                  ),
                ),
                _buildBottomAction(context, state, canClaim, hasShareCode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          IconButton(
            tooltip: '返回首页',
            onPressed: () => context.go(RouteNames.home),
            icon: const Icon(Icons.home_outlined, size: 21, color: Colors.white),
          ),
          const Text('红包领取', style: TextStyle(fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCouponCard(String couponName, String money, String fromUserName, DateTime? shareExpireTime) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBC9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8C889)),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(
              fromUserName.isEmpty ? '好友送你一份红包权益' : '$fromUserName 送你一份红包权益',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3A3A3A)),
            ),
            const SizedBox(height: 18),
            Text(
              couponName.isEmpty ? '待解锁红包' : couponName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: Color(0xFF183E72), height: 1.25),
            ),
            const SizedBox(height: 10),
            Text(
              '￥$money',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: Color(0xFFE05527), height: 1.1),
            ),
            if (shareExpireTime != null) ...[
              const SizedBox(height: 14),
              Text(
                '分享有效期至 ${_formatDate(shareExpireTime)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFF777777)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(String productName, String rebate, DateTime? startTime, DateTime? endTime, String remark, String activityHtml) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '红包详情',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF202124)),
          ),
          if (productName.isNotEmpty) _detailRow('限定商品', productName),
          _detailRow('老用户返利', '￥$rebate'),
          if (startTime != null || endTime != null) _detailRow('使用期限', '${_formatDate(startTime)} 至 ${_formatDate(endTime)}'),
          if (activityHtml.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(activityHtml, style: const TextStyle(fontSize: 12, color: Color(0xFF555555), height: 1.6)),
          ],
          //if (activityHtml.trim().isNotEmpty) ...[const SizedBox(height: 12), HtmlWidget(activityHtml, baseUrl: Uri.parse(AppConfig.baseUrl))],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF858585))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF333333), height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildReason(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.94), borderRadius: BorderRadius.circular(8)),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: Color(0xFFB23B2E), height: 1.4),
      ),
    );
  }

  Widget _buildMessagePanel({required IconData icon, required String title, required String message}) {
    return Container(
      margin: const EdgeInsets.only(top: 48),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF79808A)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF202124)),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF777777), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, CashCouponShareReceiveState state, bool canClaim, bool hasShareCode) {
    final label = state.received
        ? '查看我的红包'
        : state.submitting
        ? '领取中...'
        : state.loading || (!state.loaded && hasShareCode)
        ? '正在核验...'
        : !hasShareCode
        ? '返回首页'
        : state.errorMessage != null && state.result == null
        ? '重试'
        : canClaim
        ? '立即领取'
        : '返回首页';

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: state.loading || state.submitting || (!state.loaded && hasShareCode)
              ? null
              : () {
                  if (state.received) {
                    context.go(RouteNames.lockedRedPacketList);
                  } else if (canClaim) {
                    _receive(context);
                  } else if (state.errorMessage != null && state.result == null && hasShareCode) {
                    ref.read(cashCouponShareReceiveProvider(widget.shareCode).notifier).load();
                  } else {
                    context.go(RouteNames.home);
                  }
                },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1F3B82),
            disabledBackgroundColor: const Color(0xFF657CA8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: state.submitting || state.loading || (!state.loaded && hasShareCode)
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Future<void> _receive(BuildContext context) async {
    final success = await ref.read(cashCouponShareReceiveProvider(widget.shareCode).notifier).receive();
    if (!context.mounted) return;
    if (!success) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('领取成功，红包已放入我的卡包'), behavior: SnackBarBehavior.floating));
  }

  static String _formatDate(DateTime? value) {
    if (value == null) return '—';
    final date = value.toLocal();
    String two(int part) => part.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}
