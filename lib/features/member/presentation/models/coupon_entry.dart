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
  final List<Color> backgroundColors;
  final List<Color> actionColors;
  final Color dividerColor;

  /// 「立即查看」胶囊按钮的渐变背景（上 → 下）。
  final List<Color> pillColors;
  final Color titleColor;
  final Color buttonTextColor;

  const CouponEntry({
    required this.type,
    required this.title,
    required this.backgroundColors,
    required this.actionColors,
    required this.dividerColor,
    required this.pillColors,
    required this.titleColor,
    required this.buttonTextColor,
  });

  static const List<CouponEntry> all = [
    CouponEntry(
      type: CouponEntryType.discount,
      title: '天佑德优惠券',
      backgroundColors: [Color(0xFFC9E0FA), Color(0xFFD9E9FB)],
      actionColors: [Color(0xFF4C8FDE), Color(0xFF3E7ED1)],
      dividerColor: Color(0xFFE2EEFB),
      pillColors: [Color(0xFFFFFFFF), Color(0xFFC9E2FA)],
      titleColor: Color(0xFF225FA8),
      buttonTextColor: Color(0xFF245FA5),
    ),
    CouponEntry(
      type: CouponEntryType.service,
      title: '天佑德服务券',
      backgroundColors: [Color(0xFFF8C795), Color(0xFFFDE4C8)],
      actionColors: [Color(0xFFF49B57), Color(0xFFE7782D)],
      dividerColor: Color(0xFFFBE5D1),
      pillColors: [Color(0xFFFFFFFF), Color(0xFFFBD9B8)],
      titleColor: Color(0xFFC04B00),
      buttonTextColor: Color(0xFFB74400),
    ),
    CouponEntry(
      type: CouponEntryType.lockedRedPacket,
      title: '待解锁红包',
      backgroundColors: [Color(0xFFFFD47C), Color(0xFFFFE7A8)],
      actionColors: [Color(0xFFFF521C), Color(0xFFF33B08)],
      dividerColor: Color(0xFFFFE7B8),
      pillColors: [Color(0xFFFFFFFF), Color(0xFFFFD8B4)],
      titleColor: Color(0xFFC43E00),
      buttonTextColor: Color(0xFFB53300),
    ),
  ];
}
