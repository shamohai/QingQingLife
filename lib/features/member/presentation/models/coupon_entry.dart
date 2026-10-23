import 'package:flutter/material.dart';

/// 我的卡券页固定入口类型。
///
/// 当前后端仅提供通用优惠券列表能力，尚无服务券、待解锁红包的独立列表接口；
/// 页面先按产品要求固定展示三类入口，后续接入各自列表页时替换 [onTap] 行为。
enum CouponEntryType { discount, service, lockedRedPacket }

/// 三张卡券入口的纯展示配置。
class CouponEntry {
  final CouponEntryType type;
  final String title;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color buttonColor;
  final Color buttonTextColor;

  const CouponEntry({
    required this.type,
    required this.title,
    required this.gradientColors,
    required this.borderColor,
    required this.buttonColor,
    required this.buttonTextColor,
  });

  static const List<CouponEntry> all = [
    CouponEntry(
      type: CouponEntryType.discount,
      title: '天佑德优惠券',
      gradientColors: [Color(0xFFF7FBFF), Color(0xFFD6E6FF)],
      borderColor: Color(0xFFB8CFF0),
      buttonColor: Color(0xFF7CC2F1),
      buttonTextColor: Color(0xFF1F5FA8),
    ),
    CouponEntry(
      type: CouponEntryType.service,
      title: '天佑德服务券',
      gradientColors: [Color(0xFFFFF9F0), Color(0xFFFFE4C8)],
      borderColor: Color(0xFFF0C79C),
      buttonColor: Color(0xFFFF8A3D),
      buttonTextColor: Color(0xFFB83E00),
    ),
    CouponEntry(
      type: CouponEntryType.lockedRedPacket,
      title: '待解锁红包',
      gradientColors: [Color(0xFFFFFBF0), Color(0xFFFFE8A8)],
      borderColor: Color(0xFFF0D56E),
      buttonColor: Color(0xFFFF4B0A),
      buttonTextColor: Color(0xFF9E2600),
    ),
  ];
}
