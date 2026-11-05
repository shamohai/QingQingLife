import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/route_names.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/network/api_response.dart';
import '../../../../order/domain/repositories/order_repository.dart';
import '../../../../order/presentation/providers/order_detail_provider.dart';
import '../../data/models/points_payment_success_data.dart';

/// 积分提交订单成功页面
///
/// 由确认订单页在真实提交订单成功后跳转至该页。根据 orderid 调用接口 `/api/order/v2/getorderdetail` 获取订单详情。
class PointsPaymentSuccessPage extends ConsumerWidget {
  final String orderNo;
  final String transactionNo;
  final int pointsDeducted;
  final String orderId;

  const PointsPaymentSuccessPage({
    super.key,
    required this.orderNo,
    required this.transactionNo,
    this.pointsDeducted = 0,
    this.orderId = '',
  });

  /// 从 GoRouter extra 构建页面
  factory PointsPaymentSuccessPage.fromExtra(dynamic extra) {
    if (extra is PointsPaymentSuccessData) {
      final effectiveOrderId = (extra.orderId != null && extra.orderId!.isNotEmpty)
          ? extra.orderId!
          : (extra.transactionNo.isNotEmpty ? extra.transactionNo : extra.orderNo);
      return PointsPaymentSuccessPage(
        orderNo: extra.orderNo,
        transactionNo: extra.transactionNo,
        pointsDeducted: extra.pointsDeducted,
        orderId: effectiveOrderId,
      );
    } else if (extra is Map) {
      final orderNo = extra['orderNo']?.toString() ?? extra['ordersn']?.toString() ?? '';
      final transactionNo = extra['transactionNo']?.toString() ?? extra['orderid']?.toString() ?? '';
      final id = extra['orderId']?.toString() ?? extra['orderid']?.toString() ?? transactionNo;
      final points = int.tryParse(extra['pointsDeducted']?.toString() ?? extra['payintegralcount']?.toString() ?? '0') ?? 0;
      return PointsPaymentSuccessPage(
        orderNo: orderNo,
        transactionNo: transactionNo,
        pointsDeducted: points,
        orderId: id,
      );
    } else if (extra is String) {
      return PointsPaymentSuccessPage(
        orderNo: extra,
        transactionNo: extra,
        orderId: extra,
      );
    }
    return const PointsPaymentSuccessPage(orderNo: '', transactionNo: '', orderId: '');
  }

  /// 跳转订单明细详情页
  void _onOrderDetail(BuildContext context, String effectiveOrderId) {
    if (effectiveOrderId.isNotEmpty) {
      context.push(RouteNames.orderDetail.replaceAll(':id', effectiveOrderId));
    } else {
      context.push('/orders');
    }
  }

  String _formatDateTime(DateTime dt) {
    if (dt.millisecondsSinceEpoch == 0) return '-';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveOrderId = orderId.isNotEmpty ? orderId : (transactionNo.isNotEmpty ? transactionNo : orderNo);
    final asyncDetail = effectiveOrderId.isNotEmpty ? ref.watch(orderDetailProvider(effectiveOrderId)) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // ── 背景：上半部 50% 纯色 #F3F5F7，下半部 50% 背景图加图层 ──
                Positioned.fill(
                  child: Column(
                    children: [
                      // 上半部 50% 纯背景色 #F3F5F7，无渐变
                      Expanded(flex: 50, child: Container(color: const Color(0xFFF3F5F7))),
                      // 下半部 50% 背景图加图层
                      Expanded(
                        flex: 50,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFF3F5F7), Color(0xFFFFFFFF)],
                            ),
                            image: DecorationImage(
                              image: AssetImage('assets/images/order/order_bottom_bg.png'),
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 内容滚动区域
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 34),
                        // 成功图标，水平居中
                        const Align(
                          alignment: Alignment.center,
                          child: Image(
                            image: AssetImage('assets/images/points/icon-success.png'),
                            width: 150,
                            height: 150,
                          ),
                        ),
                        const SizedBox(height: 1),
                        // "提交订单成功" 标签
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            '提交订单成功',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF000000),
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // ── 区域 2：订单信息白色卡片 ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 414),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.lg),
                              child: _buildOrderCardContent(context, asyncDetail, effectiveOrderId),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCardContent(
    BuildContext context,
    AsyncValue<ApiResponse<OrderDetail>>? asyncDetail,
    String effectiveOrderId,
  ) {
    if (asyncDetail == null) {
      return _buildCardFields(
        context: context,
        orderSn: orderNo.isNotEmpty ? orderNo : '-',
        orderStateDesc: '提交成功',
        payIntegralCount: pointsDeducted,
        createTimeStr: '-',
        mobileStr: '-',
        userRemarkStr: '',
        effectiveOrderId: effectiveOrderId,
      );
    }

    return asyncDetail.when(
      data: (response) {
        if (response.success && response.data != null) {
          final detail = response.data!;
          final orderSn = detail.orderNo.isNotEmpty ? detail.orderNo : (orderNo.isNotEmpty ? orderNo : '-');
          final orderStateDesc = detail.statusText.isNotEmpty ? detail.statusText : '提交成功';
          final payIntegralCount = detail.payIntegralCount ?? detail.pointsCost ?? pointsDeducted;
          final createTimeStr = _formatDateTime(detail.createTime);
          final mobileStr = (detail.mobile != null && detail.mobile!.isNotEmpty)
              ? detail.mobile!
              : (detail.address.phone.isNotEmpty ? detail.address.phone : '-');
          final userRemarkStr = (detail.userRemark ?? detail.remark ?? '').trim();

          return _buildCardFields(
            context: context,
            orderSn: orderSn,
            orderStateDesc: orderStateDesc,
            payIntegralCount: payIntegralCount,
            createTimeStr: createTimeStr,
            mobileStr: mobileStr,
            userRemarkStr: userRemarkStr,
            effectiveOrderId: effectiveOrderId,
          );
        } else {
          return _buildCardFields(
            context: context,
            orderSn: orderNo.isNotEmpty ? orderNo : '-',
            orderStateDesc: '提交成功',
            payIntegralCount: pointsDeducted,
            createTimeStr: '-',
            mobileStr: '-',
            userRemarkStr: '',
            effectiveOrderId: effectiveOrderId,
          );
        }
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildCardFields(
        context: context,
        orderSn: orderNo.isNotEmpty ? orderNo : '-',
        orderStateDesc: '提交成功',
        payIntegralCount: pointsDeducted,
        createTimeStr: '-',
        mobileStr: '-',
        userRemarkStr: '',
        effectiveOrderId: effectiveOrderId,
      ),
    );
  }

  Widget _buildCardFields({
    required BuildContext context,
    required String orderSn,
    required String orderStateDesc,
    required int payIntegralCount,
    required String createTimeStr,
    required String mobileStr,
    required String userRemarkStr,
    required String effectiveOrderId,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderInfoRow(label: '订单编码', value: orderSn),
        const SizedBox(height: AppSpacing.sm),
        OrderInfoRow(label: '订单状态', value: orderStateDesc),
        const SizedBox(height: AppSpacing.sm),
        OrderInfoRow(label: '青稞粒', value: '$payIntegralCount 粒'),
        const SizedBox(height: AppSpacing.sm),
        OrderInfoRow(label: '下单时间', value: createTimeStr),
        const SizedBox(height: AppSpacing.sm),
        OrderInfoRow(label: '手机号', value: mobileStr),
        if (userRemarkStr.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          OrderInfoRow(label: '用户备注', value: userRemarkStr),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PillButton(label: '返回首页', onTap: () => context.go(RouteNames.home)),
            const SizedBox(width: AppSpacing.md),
            PillButton(label: '订单明细', onTap: () => _onOrderDetail(context, effectiveOrderId)),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

/// 订单信息单行：左侧灰色 label，右侧黑色 value（靠右对齐）
class OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const OrderInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97), height: 1.43),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF000000), height: 1.43),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// Outline pill 按钮（134x39，radius=999）
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PillButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 134,
      height: 39,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF213775)),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.round))),
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF213775), height: 1.0),
        ),
      ),
    );
  }
}
