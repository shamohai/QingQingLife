import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/cash_coupon_model.dart';
import '../providers/locked_red_packet_provider.dart';

/// 待解锁红包详情弹层。
class LockedRedPacketDetailSheet extends ConsumerWidget {
  final String couponSn;

  const LockedRedPacketDetailSheet({super.key, required this.couponSn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(cashCouponDetailProvider(couponSn));
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    const Center(
                      child: Text(
                        '卡券详情',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface, height: 1.2),
                      ),
                    ),
                    Positioned(
                      right: AppSpacing.sm,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        tooltip: '关闭',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 26, color: AppColors.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.divider),
              Flexible(
                child: detailAsync.when(
                  loading: () => const SizedBox(height: 240, child: AppLoading()),
                  error: (_, _) => SizedBox(
                    height: 260,
                    child: AppError(message: '红包详情加载失败，请稍后重试', onRetry: () => ref.invalidate(cashCouponDetailProvider(couponSn))),
                  ),
                  data: (detail) => _DetailContent(detail: detail),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final CashCouponInfo detail;

  const _DetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final amountText = _amountText(detail);
    final requirement = detail.requirement.trim();
    final usage = detail.remark.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledText('有效期：', _validityText(detail)),
          const SizedBox(height: AppSpacing.xl),
          _buildLabeledText('返现要求：', requirement.isEmpty ? '暂无' : requirement),
          const SizedBox(height: AppSpacing.xl),
          _buildLabeledText('面额：', amountText),
          if (usage.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            const Text('使用说明：', style: _detailLabelStyle),
            const SizedBox(height: AppSpacing.sm),
            Text(usage, style: _detailTextStyle),
          ],
        ],
      ),
    );
  }

  static Widget _buildLabeledText(String label, String value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: label, style: _detailLabelStyle),
          TextSpan(text: value, style: _detailTextStyle),
        ],
      ),
    );
  }

  static const TextStyle _detailTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF4B5563), height: 1.75);
  static const TextStyle _detailLabelStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4B5563), height: 1.75);

  static String _amountText(CashCouponInfo detail) {
    if (detail.money > Decimal.zero) {
      final fixed = detail.money.toStringAsFixed(2);
      final value = fixed.endsWith('.00') ? fixed.substring(0, fixed.length - 3) : fixed;
      return '$value元';
    }
    return '暂无';
  }

  static String _validityText(CashCouponInfo detail) {
    final start = _formatDate(detail.startTime);
    final end = _formatDate(detail.endTime);
    if (start.isEmpty && end.isEmpty) return '长期有效';
    if (start.isEmpty) return '至$end';
    if (end.isEmpty) return '$start起';
    return '$start至$end';
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
