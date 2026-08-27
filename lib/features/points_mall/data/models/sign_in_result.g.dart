// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignInResult _$SignInResultFromJson(Map<String, dynamic> json) => SignInResult(
  success: json['success'] as bool,
  pointsEarned: (json['pointsEarned'] as num).toInt(),
  consecutiveDays: (json['consecutiveDays'] as num).toInt(),
  isConsecutiveBonus: json['isConsecutiveBonus'] as bool,
  bonusPoints: (json['bonusPoints'] as num).toInt(),
  message: json['message'] as String,
);

Map<String, dynamic> _$SignInResultToJson(SignInResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'pointsEarned': instance.pointsEarned,
      'consecutiveDays': instance.consecutiveDays,
      'isConsecutiveBonus': instance.isConsecutiveBonus,
      'bonusPoints': instance.bonusPoints,
      'message': instance.message,
    };

SignInCalendarResult _$SignInCalendarResultFromJson(
  Map<String, dynamic> json,
) => SignInCalendarResult(
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  records: (json['records'] as List<dynamic>)
      .map((e) => SignInDayRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalSignedDays: (json['totalSignedDays'] as num).toInt(),
  consecutiveDays: (json['consecutiveDays'] as num).toInt(),
);

Map<String, dynamic> _$SignInCalendarResultToJson(
  SignInCalendarResult instance,
) => <String, dynamic>{
  'year': instance.year,
  'month': instance.month,
  'records': instance.records,
  'totalSignedDays': instance.totalSignedDays,
  'consecutiveDays': instance.consecutiveDays,
};

SignInDayRecord _$SignInDayRecordFromJson(Map<String, dynamic> json) =>
    SignInDayRecord(
      day: (json['day'] as num).toInt(),
      isSigned: json['isSigned'] as bool,
      pointsEarned: (json['pointsEarned'] as num).toInt(),
      isToday: json['isToday'] as bool,
    );

Map<String, dynamic> _$SignInDayRecordToJson(SignInDayRecord instance) =>
    <String, dynamic>{
      'day': instance.day,
      'isSigned': instance.isSigned,
      'pointsEarned': instance.pointsEarned,
      'isToday': instance.isToday,
    };

PointsRule _$PointsRuleFromJson(Map<String, dynamic> json) =>
    PointsRule(content: json['content'] as String);

Map<String, dynamic> _$PointsRuleToJson(PointsRule instance) =>
    <String, dynamic>{'content': instance.content};
