import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/repositories/points_repository.dart';

/// 积分记录条目卡片
///
/// 渲染单条积分变动记录：图标 + 名称 + 订单号 + 积分金额 + 时间。
class PointsRecordItem extends StatelessWidget {
  final PointsExchangeRecord record;

  const PointsRecordItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isIncome = record.pointsDeducted > 0;
    final amountText = isIncome ? '+${NumberFormat('####').format(record.pointsDeducted)}积分' : '${NumberFormat('####').format(record.pointsDeducted)}积分';
    final amountColor = const Color(0xFFFF2105);
    final timeText = DateFormat('yyyy-MM-dd  HH:mm:ss').format(record.createTime);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：图标 + 名称
              Row(
                children: [
                  // 类型图标
                  _TypeIcon(isIncome: !isIncome),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.productName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface, height: 1.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // 第二行：订单编号
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '订单编号：${record.exchangeNo}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97), height: 1.43),
                ),
              ),
              // 第三行：发生时间
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '发生时间：$timeText',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97), height: 1.43),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amountText,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: amountColor, height: 1.0),
        ),
      ],
    );
  }
}

/// 记录类型图标：收入用绿色向下箭头，支出用红色向上箭头
/// （设计稿中支出为向下箭头 - 表示积分减少，收入为向上箭头 + 表示积分增加）
class _TypeIcon extends StatelessWidget {
  final bool isIncome;

  const _TypeIcon({required this.isIncome});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(4)),
      child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, size: 16, color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFFF2105)),
    );
  }
}
