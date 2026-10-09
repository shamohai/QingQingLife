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

  /// 当前等级可享权益数量（来源：getLevelBenefits 接口）
  final int benefitsCount;

  /// 未读消息数（用于头部消息图标红点角标；后端暂未提供字段，默认 0 不显示）
  final int unreadMessageCount;

  /// TODO(Mock): 会员等级到期时间 —— 后端 MemberInfo 暂无此字段，
  /// 当前使用标记 Mock 值用于 UI 还原，接入真实字段后替换。
  final DateTime? memberExpireDate;

  /// TODO(Mock): 天佑德值 —— 后端 MemberInfo / PointsAccount 暂无此字段，
  /// 当前使用标记 Mock 值用于 UI 还原，接入真实字段后替换。
  final int tianyoudeValue;

  const UserProfileState({
    this.nickname = '青轻用户_9527',
    this.avatarUrl,
    this.phoneMasked = '150****9999',
    required this.memberInfo,
    required this.points,
    required this.couponCount,
    this.expiringPoints,
    this.expiringDate,
    this.benefitsCount = 0,
    this.unreadMessageCount = 0,
    this.memberExpireDate,
    this.tianyoudeValue = 0,
  });
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfileState>(() => UserProfileNotifier());

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
      if (memberResp.success && pointsResp.success && memberResp.data != null && pointsResp.data != null) {
        final member = memberResp.data!;
        final points = pointsResp.data!;

        // 权益数量：真实接口获取，失败时降级为 0
        int benefitsCount = 0;
        try {
          final benefitsResp = await repository.getLevelBenefits(member.memberLevel);
          if (benefitsResp.success && benefitsResp.data != null) {
            benefitsCount = benefitsResp.data!.benefits.length;
          }
        } catch (e) {
          debugPrint('[UserProfile] load benefits error: $e');
        }

        state = UserProfileState(
          nickname: member.nickname,
          avatarUrl: member.avatarUrl,
          memberInfo: member,
          points: points.availablePoints,
          couponCount: member.availableCoupons,
          expiringPoints: points.expiringPoints > 0 ? points.expiringPoints : null,
          expiringDate: points.expiringDate,
          benefitsCount: benefitsCount,
          // TODO(Mock): 以下两个值后端暂无对应字段，使用标记 Mock 值做 UI 还原
          memberExpireDate: DateTime(2027, 10, 1),
          tianyoudeValue: 1500,
        );
      }
    } catch (e) {
      debugPrint('[UserProfile] load error: $e');
    }
  }
}
