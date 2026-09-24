import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../providers/member_level_provider.dart';

/// 会员详情页 - 等级信息卡片（白色圆角卡片）
///
/// 布局：等级名 + 「成长值/升级门槛」（左）+ 金色等级徽章（右），
/// 下方依次为权益数量提示与达标提示。
class MemberSummaryCard extends StatelessWidget {
  final MemberLevelOption level;

  /// 用户当前成长值（来源「我的」页全局会员状态）
  final int growthValue;

  const MemberSummaryCard({super.key, required this.level, required this.growthValue});

  /// 权益数量中文数字（1~10），超出范围回退为阿拉伯数字
  static const List<String> _cnNumbers = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];

  static String _cnNum(int n) => n >= 0 && n <= 10 ? _cnNumbers[n] : '$n';

  @override
  Widget build(BuildContext context) {
    final reached = growthValue >= level.growthThreshold;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 左侧信息列 ────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 等级名 + 成长值/门槛
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        level.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1B3C70), height: 1.1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      reached ? '已达成' : '${growthValue}/${level.growthThreshold}升级',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2E7CD6)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 权益数量
                Row(
                  children: [
                    const Icon(Icons.diamond, size: 16, color: Color(0xFFE0A26E)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '可尊享${_cnNum(level.cardBenefitsCount)}项会员权益',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF3A4A5A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 达标提示
                Text(
                  reached ? '已达到该等级，继续保持！' : '暂未达到该等级，怎能轻易认输！',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF94A7BC)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── 右侧金色等级徽章 ──────────────────────────────────────
          Image.asset('assets/images/member/member_badge_level.webp', width: 84, fit: BoxFit.contain),
        ],
      ),
    );
  }
}
