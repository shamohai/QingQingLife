import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../data/models/points_payment_success_data.dart';

/// 积分支付成功页面
///
/// 由确认订单页（ConfirmOrderPage）在提交订单后跳转至该页。
/// 数据来源：PointsExchangeResult（mock），字段通过构造函数传入。
class PointsPaymentSuccessPage extends StatelessWidget {
  final String orderNo;
  final String transactionNo;
  final int pointsDeducted;

  const PointsPaymentSuccessPage({super.key, required this.orderNo, required this.transactionNo, this.pointsDeducted = 0});

  /// 从 GoRouter extra 构建页面
  factory PointsPaymentSuccessPage.fromExtra(dynamic extra) {
    if (extra is PointsPaymentSuccessData) {
      return PointsPaymentSuccessPage(orderNo: extra.orderNo, transactionNo: extra.transactionNo, pointsDeducted: extra.pointsDeducted);
    }
    // 无数据时降级为 mock
    return const PointsPaymentSuccessPage(orderNo: 'DDBH45674568908765789', transactionNo: 'DDBH45654087654678908765789');
  }

  /// 跳转订单明细（路由暂未实现，暂返回上一页并 toast 提示）
  void _onOrderDetail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('订单明细功能开发中')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // ── 区域 1：渐变 Header 背景 ──
                Container(
                  height: 330,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFC65E), Color(0xFFF3F5F7)]),
                  ),
                ),
                // 内容滚动区域
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 34),
                      // 成功图标，水平居中
                      const Align(
                        alignment: Alignment.center,
                        child: Image(image: AssetImage('assets/images/points/icon-success.png'), width: 150, height: 150),
                      ),
                      const SizedBox(height: 1),
                      // "兑换成功" 标签
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          '兑换成功',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF000000), height: 1.0),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // ── 区域 2：订单信息白色卡片 ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 414),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.sm)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OrderInfoRow(label: '订单编号', value: orderNo),
                                const SizedBox(height: AppSpacing.sm),
                                OrderInfoRow(label: '交易单号', value: transactionNo),
                                const SizedBox(height: AppSpacing.sm),
                                OrderInfoRow(label: '交易状态', value: '兑换成功'),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    PillButton(label: '返回首页', onTap: () => Navigator.of(context).pop()),
                                    const SizedBox(width: AppSpacing.md),
                                    PillButton(label: '订单明细', onTap: () => _onOrderDetail(context)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── 区域 3：底部安全区占位条 ──
          const Image(image: AssetImage('assets/images/points/payment_success_bottom_bar.png'), width: double.infinity, height: 60, fit: BoxFit.cover),
        ],
      ),
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
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97), height: 1.43),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF000000), height: 1.43),
            maxLines: 1,
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF213775), height: 1.0),
        ),
      ),
    );
  }
}
