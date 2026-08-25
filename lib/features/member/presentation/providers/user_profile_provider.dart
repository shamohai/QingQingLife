import 'package:flutter_riverpod/flutter_riverpod.dart';


class MemberInfo {
  final int level;
  final String levelName;
  final int points;
  final int exp;
  final int nextLevelExp;
  const MemberInfo({this.level = 2, this.levelName = '银卡会员', this.points = 3580, this.exp = 680, this.nextLevelExp = 1000});
}

final userProfileProvider = Provider<UserProfileProvider>((ref) => const UserProfileProvider());

class UserProfileProvider {
  const UserProfileProvider();
  MemberInfo get memberInfo => const MemberInfo();
  String get nickname => '青轻用户_9527';
  String? get avatarUrl => null;
}
