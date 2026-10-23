import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/service_product_detail_model.dart';

class ConfirmOrderBottomBar extends ConsumerWidget {
  final ServiceProductDetail product;
  final int quantity;
  final int pointsBalance;
  final VoidCallback onSubmit;

  const ConfirmOrderBottomBar({
    super.key,
    required this.product,
    required this.quantity,
    required this.pointsBalance,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPoints = product.points * quantity;
    final isPointsEnough = pointsBalance >= totalPoints;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '合计：',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF1F2024)),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '$totalPoints',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFFE273D),
                              height: 1.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Text(
                          '积分',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFFE273D), height: 1.1),
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
              const SizedBox(width: 20),
              GestureDetector(
                onTap: isPointsEnough ? onSubmit : null,
                child: Opacity(
                  opacity: isPointsEnough ? 1.0 : 0.5,
                  child: Container(
                    width: 156,
                    height: 47,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3152AF), Color(0xFF213775)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
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
