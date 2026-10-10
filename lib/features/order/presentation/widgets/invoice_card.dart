import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../domain/repositories/invoice_repository.dart';

/// 发票卡片
///
/// 布局（对齐设计稿）：
/// ┌──────────────────────────────────────┐
/// │ 订单商品标题（省略）        [状态徽章 >] │
/// │ 订单类型              商城订单          │
/// │ 发票类型              数电普票          │
/// │ 订单编号             DDBH3456789       │
/// │ ──────────────────────────────────── │
/// │ 2026-10-01 12:30:09   开票金额: ¥800.00│
/// └──────────────────────────────────────┘
class InvoiceCard extends StatelessWidget {
  final InvoiceSummary invoice;

  const InvoiceCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 0, 0),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 标题 + 状态徽章 ────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  invoice.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C)),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: invoice.status),
            ],
          ),
          const SizedBox(height: 12),
          // ── 订单信息三行 ──────────────────────────────────────────
          _InfoRow(label: '订单类型', value: invoice.orderTypeText),
          _InfoRow(label: '发票类型', value: invoice.invoiceTypeText),
          _InfoRow(label: '订单编号', value: invoice.orderNo),
          const SizedBox(height: 12),
          // ── 分割线 + 时间/金额 ────────────────────────────────────
          Container(height: 0.5, color: const Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 16, 14),
            child: Row(
              children: [
                Text(
                  _formatTime(invoice.createTime),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF213775)),
                ),
                const Spacer(),
                const Text(
                  '开票金额:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1D1C)),
                ),
                const SizedBox(width: 4),
                _AmountText(amountCents: invoice.amountCents),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final mm = time.month.toString().padLeft(2, '0');
    final dd = time.day.toString().padLeft(2, '0');
    final hh = time.hour.toString().padLeft(2, '0');
    final mi = time.minute.toString().padLeft(2, '0');
    final ss = time.second.toString().padLeft(2, '0');
    return '${time.year}-$mm-$dd $hh:$mi:$ss';
  }
}

// ── 状态徽章（待开票=浅蓝底深蓝字 / 已开票=深蓝底白字） ──────────────────
class _StatusBadge extends StatelessWidget {
  final InvoiceStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isInvoiced = status == InvoiceStatus.invoiced;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isInvoiced ? const Color(0xFF213775) : const Color(0xFFE9EEF8),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppRadius.sm), bottomLeft: Radius.circular(AppRadius.sm)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isInvoiced ? Colors.white : const Color(0xFF213775)),
          ),
          const SizedBox(width: 2),
          Icon(Icons.chevron_right, size: 14, color: isInvoiced ? Colors.white : const Color(0xFF213775)),
        ],
      ),
    );
  }
}

// ── 订单信息行（label 左灰 / value 右灰） ───────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

// ── 金额（¥ 与小数小号、整数大号，红色） ─────────────────────────────────
class _AmountText extends StatelessWidget {
  final int amountCents;

  const _AmountText({required this.amountCents});

  @override
  Widget build(BuildContext context) {
    final yuan = amountCents / 100;
    final yuanInt = yuan.toInt();
    final decimal = (yuan - yuanInt).toStringAsFixed(2).substring(1);
    const color = Color(0xFFFF4030);
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontWeight: FontWeight.w600, color: color),
        children: [
          const TextSpan(text: '¥', style: TextStyle(fontSize: 12)),
          TextSpan(text: yuanInt.toString(), style: const TextStyle(fontSize: 18)),
          TextSpan(text: decimal, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
