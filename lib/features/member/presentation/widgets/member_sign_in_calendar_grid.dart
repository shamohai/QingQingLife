import 'package:flutter/material.dart';

import '../../data/models/member_sign_in_models.dart';

/// 签到日历卡片（设计稿第一张卡片）
///
/// 结构：标题「已连续签到 N 天了」+ 7 天签到宫格。
/// 宫格：第一行 4 格；第二行 2 格 + 1 个双列宽格（第 7 天），
/// 列宽比例 76:76:163 与设计稿宫格（含 11 间距）等宽。
class MemberSignInCalendarGrid extends StatelessWidget {
  /// 已连续签到天数
  final int consecutiveDays;

  /// 7 天签到数据（按日期顺序）
  final List<MemberSignInDay> days;

  const MemberSignInCalendarGrid({super.key, required this.consecutiveDays, required this.days});

  @override
  Widget build(BuildContext context) {
    final row1 = days.take(4).toList();
    final row2 = days.skip(4).take(3).toList();

    return ClipPath(
      clipper: _SignInCardTopClipper(),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFFDFEBFF), borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.fromLTRB(9, 12, 9, 6.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 17),
            Row(
              children: [
                for (var i = 0; i < row1.length; i++) ...[Expanded(child: _SignInDayCell(day: row1[i])), if (i < row1.length - 1) const SizedBox(width: 11)],
              ],
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                for (var i = 0; i < row2.length; i++) ...[
                  Expanded(
                    flex: i < 2 ? 76 : 163,
                    child: _SignInDayCell(day: row2[i]),
                  ),
                  if (i < row2.length - 1) const SizedBox(width: 11),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 标题「已连续签到 3 天了」（天数使用蓝色加粗；行高对齐设计稿，保证宫格顶部位置）
  Widget _buildTitle() {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: '已连续签到'),
          TextSpan(
            text: '$consecutiveDays',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0686FF), height: 1.156),
          ),
          const TextSpan(text: '天了'),
        ],
      ),
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF14213A), height: 1.228),
    );
  }
}

/// 单个签到日单元格（+N 积分 / 日历图标 / 日期）
class _SignInDayCell extends StatelessWidget {
  final MemberSignInDay day;

  const _SignInDayCell({required this.day});

  @override
  Widget build(BuildContext context) {
    final style = _CellStyle.of(day.state);

    return Container(
      height: 75,
      decoration: BoxDecoration(color: style.background, borderRadius: BorderRadius.circular(9)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '+${day.points}',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: style.points, height: 1.1),
          ),
          const SizedBox(height: 4),
          Icon(Icons.event_available_outlined, size: 21, color: style.icon),
          const SizedBox(height: 4),
          Text(
            day.label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: style.date, height: 1.1),
          ),
        ],
      ),
    );
  }
}

/// 单元格配色（按状态）
class _CellStyle {
  final Color background;
  final Color points;
  final Color icon;
  final Color date;

  const _CellStyle({required this.background, required this.points, required this.icon, required this.date});

  static _CellStyle of(MemberSignInDayState state) {
    switch (state) {
      case MemberSignInDayState.signed:
        return const _CellStyle(background: Color(0xFFDFD7F0), points: Color(0xFFDF312D), icon: Color(0xFFDF312D), date: Color(0xFF9DA4BC));
      case MemberSignInDayState.today:
        return const _CellStyle(background: Color(0xFF22418A), points: Colors.white, icon: Color(0xFFC8D3EE), date: Color(0xFFA9B6D8));
      case MemberSignInDayState.upcoming:
        return const _CellStyle(background: Color(0xFFC9D9FF), points: Color(0xFF2C3B5E), icon: Color(0xFF8A97BA), date: Color(0xFF96A0B6));
    }
  }
}

/// 卡片1顶部异形边缘（设计稿：左侧顶边高，经 S 形曲线平滑下探到右侧低位顶边）
class _SignInCardTopClipper extends CustomClipper<Path> {
  /// 左侧平直段结束位置（本地坐标）
  static const double _dipStartX = 179.6;

  /// 右侧平直段起始位置（本地坐标）
  static const double _dipEndX = 205.2;

  /// 右侧顶边相对左侧顶边的下沉高度（本地坐标）
  static const double _dropY = 32.4;

  /// 圆角半径
  static const double _radius = 10;

  @override
  Path getClip(Size size) {
    const r = _radius;
    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(_dipStartX, 0)
      // S 形曲线：三次贝塞尔控制点取两端点 1/3、2/3 处（等价于 smoothstep 过渡）
      ..cubicTo(_dipStartX + (_dipEndX - _dipStartX) / 3, 0, _dipStartX + (_dipEndX - _dipStartX) * 2 / 3, _dropY, _dipEndX, _dropY)
      ..lineTo(size.width - r, _dropY)
      ..arcToPoint(Offset(size.width, _dropY + r), radius: const Radius.circular(r))
      ..lineTo(size.width, size.height - r)
      ..arcToPoint(Offset(size.width - r, size.height), radius: const Radius.circular(r))
      ..lineTo(r, size.height)
      ..arcToPoint(Offset(0, size.height - r), radius: const Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
