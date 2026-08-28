import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/member_repository.dart';
import '../../../../core/providers/repository_providers.dart';

class UserProfileState {
  final String nickname;
  final String? avatarUrl;
  final String phoneMasked;
  final MemberInfo memberInfo;
  final int points;
  final int couponCount;
  final int? expiringPoints;
  final DateTime? expiringDate;

  const UserProfileState({
    this.nickname = '青轻用户_9527',
    this.avatarUrl,
    this.phoneMasked = '150****9999',
    required this.memberInfo,
    required this.points,
    required this.couponCount,
    this.expiringPoints,
    this.expiringDate,
  });
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfileState>(
  () => UserProfileNotifier(),
);

class UserProfileNotifier extends Notifier<UserProfileState> {
  @override
  UserProfileState build() {
    return const UserProfileState(memberInfo: MemberInfo.empty(), points: 0, couponCount: 0);
  }

  Future<void> load() async {
    final repository = ref.read(memberRepositoryProvider);
    try {
      final memberResp = await repository.getMemberInfo();
      final pointsResp = await repository.getPointsAccount();
      if (memberResp.success && pointsResp.success) {
        state = UserProfileState(
          nickname: memberResp.data!.nickname,
          avatarUrl: memberResp.data!.avatarUrl,
          memberInfo: memberResp.data!,
          points: pointsResp.data!.availablePoints,
          couponCount: memberResp.data!.availableCoupons,
          expiringPoints: pointsResp.data!.expiringPoints > 0 ? pointsResp.data!.expiringPoints : null,
          expiringDate: pointsResp.data!.expiringDate,
        );
      }
    } catch (e) {
      debugPrint('[UserProfile] load error: ');
    }
  }
}
