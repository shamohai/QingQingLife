import 'package:flutter/material.dart';

import '../../data/models/member_sign_in_models.dart';

/// 连续签到奖励卡片（设计稿第二张卡片）
///
/// 结构：标题「连续签到奖励」+ 说明文案「连续签到可获得以下奖励」，
/// 下方为奖励节点胶囊（已达成深色胶囊）与节点间进度连线，节点标签居中于胶囊下方。
class MemberSignInMilestoneTrack extends StatelessWidget {
  final List<MemberSignInMilestone> milestones;

  const MemberSignInMilestoneTrack({super.key, required this.milestones});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFDFEBFF), borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.fromLTRB(9, 13, 9, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题 + 说明文案（基线对齐）
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '连续签到奖励',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF16233C), height: 1.13),
              ),
              SizedBox(width: 6),
              Text(
                '连续签到可获得以下奖励',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF9DA3B0)),
              ),
            ],
          ),
          const SizedBox(height: 16.5),
          // 节点胶囊 + 进度连线
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < milestones.length; i++) ...[
                _MilestonePill(milestone: milestones[i]),
                if (i < milestones.length - 1) Expanded(child: _Connector(progress: milestones[i].connectorProgress)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// 奖励节点胶囊 + 节点标签
class _MilestonePill extends StatelessWidget {
  final MemberSignInMilestone milestone;

  const _MilestonePill({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final reached = milestone.reached;

    return Column(
      children: [
        Container(
          height: 20,
          padding: const EdgeInsets.symmetric(horizontal: 6.5),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: reached ? const Color(0xFF22418A) : const Color(0xFFD6E3F8), borderRadius: BorderRadius.circular(10)),
          child: Text(
            '奖励${milestone.rewardPoints}积分',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: reached ? Colors.white : const Color(0xFF8197C4), height: 1.2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          milestone.label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: reached ? const Color(0xFF26448C) : const Color(0xFFA0ACC3), height: 1.2),
        ),
      ],
    );
  }
}

/// 节点间进度连线（蓝色完成进度 + 灰色未完成部分，居中于胶囊高度）
class _Connector extends StatelessWidget {
  final double progress;

  const _Connector({required this.progress});

  static const Color _doneColor = Color(0xFF0686FF);
  static const Color _pendingMilestoneColor = Color(0xFFC6D2E6);

  @override
  Widget build(BuildContext context) {
    final flex = (progress * 1000).round().clamp(0, 1000);

    Widget line;
    if (flex <= 0) {
      line = const ColoredBox(color: _pendingMilestoneColor);
    } else if (flex >= 1000) {
      line = const ColoredBox(color: _doneColor);
    } else {
      line = Row(
        children: [
          Expanded(
            flex: flex,
            child: const ColoredBox(color: _doneColor),
          ),
          Expanded(
            flex: 1000 - flex,
            child: const ColoredBox(color: _pendingMilestoneColor),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: SizedBox(height: 2, width: double.infinity, child: line),
    );
  }
}
