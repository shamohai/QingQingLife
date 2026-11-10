import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum AppPriceSize {
  small,
  medium,
  large,
}

/// 电商规范价格展示组件
///
/// 格式化 RMB 符号、整数位、小数位及划线原价，
/// 支持根据 AppPriceSize 动态选择字号大小。
class AppPriceText extends StatelessWidget {
  const AppPriceText({
    super.key,
    required this.priceCents,
    this.originalPriceCents,
    this.symbol = '¥',
    this.unit = '',
    this.size = AppPriceSize.medium,
    this.priceColor = AppColors.error,
    this.originalPriceColor = const Color(0xFF999999),
    this.showDecimal = true,
  });

  /// 现价（分）
  final int priceCents;

  /// 原价（分，可选，传入时自动展示划线价）
  final int? originalPriceCents;

  /// 货币/积分符号（默认 ¥）
  final String symbol;

  /// 单位文案（如 /件）
  final String unit;

  /// 尺寸级别
  final AppPriceSize size;

  /// 现价颜色
  final Color priceColor;

  /// 原价颜色
  final Color originalPriceColor;

  /// 是否显示两位小数
  final bool showDecimal;

  @override
  Widget build(BuildContext context) {
    final yuan = priceCents / 100.0;
    final String yuanStr = yuan.floor().toString();
    final String decimalStr = (priceCents % 100).toString().padLeft(2, '0');

    double symbolFontSize;
    double integerFontSize;
    double decimalFontSize;
    double originalFontSize;

    switch (size) {
      case AppPriceSize.small:
        symbolFontSize = 10;
        integerFontSize = 14;
        decimalFontSize = 10;
        originalFontSize = 10;
        break;
      case AppPriceSize.medium:
        symbolFontSize = 12;
        integerFontSize = 18;
        decimalFontSize = 12;
        originalFontSize = 12;
        break;
      case AppPriceSize.large:
        symbolFontSize = 14;
        integerFontSize = 24;
        decimalFontSize = 14;
        originalFontSize = 14;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (symbol.isNotEmpty)
          Text(
            symbol,
            style: TextStyle(
              color: priceColor,
              fontSize: symbolFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        Text(
          yuanStr,
          style: TextStyle(
            color: priceColor,
            fontSize: integerFontSize,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        if (showDecimal)
          Text(
            '.$decimalStr',
            style: TextStyle(
              color: priceColor,
              fontSize: decimalFontSize,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        if (unit.isNotEmpty)
          Text(
            unit,
            style: TextStyle(
              color: const Color(0xFF666666),
              fontSize: decimalFontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
        if (originalPriceCents != null && originalPriceCents! > priceCents) ...[
          const SizedBox(width: 4),
          Text(
            '$symbol${(originalPriceCents! / 100).toStringAsFixed(showDecimal ? 2 : 0)}',
            style: TextStyle(
              color: originalPriceColor,
              fontSize: originalFontSize,
              decoration: TextDecoration.lineThrough,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
