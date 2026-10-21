import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// 订单金额统一分层排版：前缀/小数/单位小字号，整数主金额大字号。
class OrderAmountText extends StatelessWidget {
  final String value;
  final double mainFontSize;
  final Color color;

  const OrderAmountText({super.key, required this.value, required this.mainFontSize, this.color = AppColors.onSurface});

  @override
  Widget build(BuildContext context) {
    final match = RegExp(r'^([^\d]*)(\d+)(\.\d+)?(.*)$').firstMatch(value.trim());
    if (match == null) {
      return Text(
        value,
        style: TextStyle(fontSize: mainFontSize, fontWeight: FontWeight.w600, color: color),
      );
    }

    final prefix = match.group(1) ?? '';
    final integer = match.group(2) ?? '';
    final decimal = match.group(3) ?? '';
    final suffix = match.group(4) ?? '';
    final smallStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color);
    return RichText(
      text: TextSpan(
        style: TextStyle(color: color),
        children: [
          if (prefix.isNotEmpty) TextSpan(text: prefix, style: smallStyle),
          TextSpan(
            text: integer,
            style: TextStyle(fontSize: mainFontSize, fontWeight: FontWeight.w600, color: color),
          ),
          if (decimal.isNotEmpty) TextSpan(text: decimal, style: smallStyle),
          if (suffix.isNotEmpty) TextSpan(text: suffix, style: smallStyle),
        ],
      ),
    );
  }
}
