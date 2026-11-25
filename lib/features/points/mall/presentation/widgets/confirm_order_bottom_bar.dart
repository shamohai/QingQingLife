import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/service_product_detail_model.dart';

class ConfirmOrderBottomBar extends ConsumerWidget {
  final ServiceProductDetail product;
  final int quantity;
  final int pointsBalance;
  final bool isSubmitting;
  final bool isBenefit;
  final VoidCallback onSubmit;

  const ConfirmOrderBottomBar({
    super.key,
    required this.product,
    required this.quantity,
    required this.pointsBalance,
    this.isSubmitting = false,
    this.isBenefit = false,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 合计积分始终按单价 × 数量展示
    final totalPoints = product.points * quantity;
    // 权益进入无需支付积分，跳过余额校验；普通商品需积分余额足够才可提交
    final isPointsEnough = isBenefit || pointsBalance >= totalPoints;
    final isClickable = isPointsEnough && !isSubmitting;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '合计：',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF1F2024)),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Flexible(
                                child: Text(
                                  '$totalPoints',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFFE273D),
                                    height: 1.1,
                                    decoration: isBenefit ? TextDecoration.lineThrough : TextDecoration.none,
                                    decorationColor: const Color(0xFFFE273D),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '积分',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFFE273D),
                                  height: 1.1,
                                  decoration: isBenefit ? TextDecoration.lineThrough : TextDecoration.none,
                                  decorationColor: const Color(0xFFFE273D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '剩余$pointsBalance积分',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFFFF2105)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: isClickable ? onSubmit : null,
                child: Opacity(
                  opacity: isClickable ? 1.0 : 0.5,
                  child: Container(
                    width: 156,
                    height: 47,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3152AF), Color(0xFF213775)]),
                    ),
                    child: Center(
                      child: isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                              '提交订单',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
