import 'package:json_annotation/json_annotation.dart';

part 'sign_in_result.g.dart';

/// 签到结果
@JsonSerializable()
class SignInResult {
  final bool success;
  final int pointsEarned;
  final int consecutiveDays;
  final bool isConsecutiveBonus;
  final int bonusPoints;
  final String message;

  const SignInResult({
    required this.success,
    required this.pointsEarned,
    required this.consecutiveDays,
    required this.isConsecutiveBonus,
    required this.bonusPoints,
    required this.message,
  });

  factory SignInResult.fromJson(Map<String, dynamic> json) => _$SignInResultFromJson(json);

  Map<String, dynamic> toJson() => _$SignInResultToJson(this);
}

/// 签到日历结果
@JsonSerializable()
class SignInCalendarResult {
  final int year;
  final int month;
  final List<SignInDayRecord> records;
  final int totalSignedDays;
  final int consecutiveDays;

  const SignInCalendarResult({
    required this.year,
    required this.month,
    required this.records,
    required this.totalSignedDays,
    required this.consecutiveDays,
  });

  factory SignInCalendarResult.fromJson(Map<String, dynamic> json) => _$SignInCalendarResultFromJson(json);

  Map<String, dynamic> toJson() => _$SignInCalendarResultToJson(this);
}

/// 签到日记录
@JsonSerializable()
class SignInDayRecord {
  final int day;
  final bool isSigned;
  final int pointsEarned;
  final bool isToday;

  const SignInDayRecord({required this.day, required this.isSigned, required this.pointsEarned, required this.isToday});

  factory SignInDayRecord.fromJson(Map<String, dynamic> json) => _$SignInDayRecordFromJson(json);

  Map<String, dynamic> toJson() => _$SignInDayRecordToJson(this);
}

/// 积分规则
@JsonSerializable()
class PointsRule {
  final String content;

  const PointsRule({required this.content});

  factory PointsRule.fromJson(Map<String, dynamic> json) => _$PointsRuleFromJson(json);

  Map<String, dynamic> toJson() => _$PointsRuleToJson(this);
}
