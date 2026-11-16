import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';

/// 商城订单提交成功页所需的展示数据。
///
/// 后端提交接口只返回订单号，不返回支付交易号，因此不在客户端生成交易号。
class MallPaymentSuccessData {
  const MallPaymentSuccessData({
    required this.orderId,
    required this.orderNo,
    required this.amountCents,
    required this.discountCents,
    this.paymentMethod = '微信支付',
  });

  final String orderId;
  final String orderNo;
  final int amountCents;
  final int discountCents;
  final String paymentMethod;
}

/// 商城订单提交成功页。
///
/// 正常下单流程通过 `extra` 传入 [MallPaymentSuccessData]；
/// 缺参时显示空态，不再渲染假订单数据。
class MallPaymentSuccessPage extends StatelessWidget {
  const MallPaymentSuccessPage({super.key, this.data});

  final MallPaymentSuccessData? data;

  factory MallPaymentSuccessPage.fromExtra(dynamic extra) {
    if (extra is MallPaymentSuccessData) {
      return MallPaymentSuccessPage(data: extra);
    }
    return const MallPaymentSuccessPage();
  }

  @override
  Widget build(BuildContext context) {
    final payment = data;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        bottom: false,
        child: payment == null
            ? _MissingDataView(onBack: () => _goBack(context))
            : Stack(
                children: [
                  const _TopGradient(),
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 52, 12, 32),
                    child: Column(
                      children: [
                        _SuccessHeader(data: payment),
                        const SizedBox(height: 39),
                        _PaymentSummaryCard(data: payment),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.orders);
    }
  }
}

/// 缺少支付信息时的空态视图。
class _MissingDataView extends StatelessWidget {
  const _MissingDataView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFF8E8E93)),
          const SizedBox(height: 16),
          const Text('订单信息已失效', style: TextStyle(fontSize: 16, color: Color(0xFF3A3A3A))),
          const SizedBox(height: 24),
          _OutlineButton(label: '返回', onPressed: onBack),
        ],
      ),
    );
  }
}

class _TopGradient extends StatelessWidget {
  const _TopGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 430,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE0E8FF), Color(0x00F3F5F7)]),
        ),
      ),
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({required this.data});

  final MallPaymentSuccessData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(color: Color(0xFF42AE35), shape: BoxShape.circle),
          child: const Icon(Icons.check, size: 34, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          '订单提交成功',
          style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: '¥', style: TextStyle(fontSize: 24, height: 1)),
              TextSpan(text: (data.amountCents / 100).toStringAsFixed(2), style: const TextStyle(fontSize: 40, height: 1)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('已减免${(data.discountCents / 100).toStringAsFixed(0)}元', style: const TextStyle(fontSize: 16, height: 1.4, color: Color(0xFFFF2105))),
      ],
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard({required this.data});

  final MallPaymentSuccessData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 21, 10, 22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _InfoRow(label: '订单编号', value: data.orderNo),
          const SizedBox(height: 14),
          _InfoRow(label: '支付方式', value: data.paymentMethod, leading: Icons.wechat),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _OutlineButton(label: '返回首页', onPressed: () => context.go(RouteNames.home)),
              _OutlineButton(label: '订单明细', onPressed: () => context.push('/orders/${data.orderId}')),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.leading});

  final String label;
  final String value;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: const TextStyle(fontSize: 14, height: 1.43, color: Color(0xFF8E8E93)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (leading != null) ...[const Icon(Icons.wechat, size: 20, color: Color(0xFF07C160)), const SizedBox(width: 6)],
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 14, height: 1.43, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 134,
      height: 39,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: Color(0xFF213775)),
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, height: 1, fontWeight: FontWeight.w500, color: Color(0xFF213775)),
        ),
      ),
    );
  }
}
