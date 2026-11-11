/// 会员签到相关模型
///
/// 后端签到接口尚未提供，字段按设计稿定义；接口就绪后按真实返回字段校准。
library;

/// 签到日历单元格状态
enum MemberSignInDayState {
  /// 已签到（今天之前的日期）
  signed,

  /// 今天
  today,

  /// 未签到（未来日期）
  upcoming,
}

/// 签到日历中的单日单元格
class MemberSignInDay {
  /// 日期标签（如 10月1日）
  final String label;

  /// 该日可获得的积分
  final int points;

  /// 单元格状态
  final MemberSignInDayState state;

  const MemberSignInDay({required this.label, required this.points, required this.state});
}

/// 连续签到奖励节点
class MemberSignInMilestone {
  /// 节点标签（如 第1天）
  final String label;

  /// 节点奖励积分
  final int rewardPoints;

  /// 是否已达成（已达成节点为深色胶囊）
  final bool reached;

  /// 与下一节点连线的完成进度 0~1（1 表示整段连线已完成）
  final double connectorProgress;

  const MemberSignInMilestone({required this.label, required this.rewardPoints, required this.reached, required this.connectorProgress});
}

/// 签到明细记录
class MemberSignInRecord {
  /// 日期文案（如 2026年10月4日）
  final String date;

  /// 类型文案（如 日常签到 / 连续签到奖励）
  final String subtitle;

  /// 获得积分（正数）
  final int points;

  const MemberSignInRecord({required this.date, required this.subtitle, required this.points});
}

/// 会员签到页总览数据
class MemberSignInOverview {
  /// 我的积分
  final int points;

  /// 已连续签到天数
  final int consecutiveDays;

  /// 签到日历（7 天）
  final List<MemberSignInDay> days;

  /// 连续签到奖励节点
  final List<MemberSignInMilestone> milestones;

  /// 签到明细
  final List<MemberSignInRecord> records;

  /// 今日是否已签到
  final bool signedToday;

  const MemberSignInOverview({
    required this.points,
    required this.consecutiveDays,
    required this.days,
    required this.milestones,
    required this.records,
    required this.signedToday,
  });
}

/// 签到动作结果
class MemberSignInResult {
  /// 是否签到成功
  final bool signed;

  /// 本次获得积分
  final int pointsEarned;

  /// 提示文案
  final String message;

  const MemberSignInResult({required this.signed, required this.pointsEarned, required this.message});
}
