import 'package:flutter/material.dart';

import '../../data/models/member_sign_in_models.dart';

/// 签到明细卡片（设计稿第三张卡片）
///
/// 结构：标题「签到明细」+ 记录列表（日期 / 类型 + 右侧积分）。
class MemberSignInRecords extends StatelessWidget {
  final List<MemberSignInRecord> records;

  const MemberSignInRecords({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFDFEBFF), borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.fromLTRB(9, 13, 9, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '签到明细',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF16233C), height: 1.08),
          ),
          const SizedBox(height: 16.5),
          for (final record in records) _RecordRow(record: record),
        ],
      ),
    );
  }
}

/// 单条签到记录
class _RecordRow extends StatelessWidget {
  final MemberSignInRecord record;

  const _RecordRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.date,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B2740), height: 1.286),
                ),
                const SizedBox(height: 3),
                Text(
                  record.subtitle,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF9CA9C0), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+${record.points}积分',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0686FF)),
          ),
        ],
      ),
    );
  }
}
