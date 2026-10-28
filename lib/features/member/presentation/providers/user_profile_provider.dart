import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/member_rank_models.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/domain/repositories/auth_repository.dart' show UserInfo;

class UserProfileState {
  final String nickname;
  final String? avatarUrl;
  final String phoneMasked;
  final int points;
  final int couponCount;
  final int? expiringPoints;
  final DateTime? expiringDate;

  /// 性别：0 未知 / 1 男 / 2 女（getmyprofile baseprofile.gender）
  final int gender;

  /// 性别展示名（getmyprofile baseprofile.gendername，为空时按 gender 兜底）
  final String genderName;

  /// 生日（getmyprofile baseprofile.birthday）
  final DateTime? birthday;

  /// 地址文本（getmyprofile 顶层 address）
  final String? address;

  /// 会员等级列表（getranklist）
  final List<RankBaseInfo> ranks;

  /// 当前等级（按 memberLevel 匹配 ranks，匹配不到取首项）
  RankBaseInfo? get currentRank {
    if (ranks.isEmpty) return null;
    final idx = ranks.indexWhere((e) => e.userrid == memberLevel);
    return idx >= 0 ? ranks[idx] : ranks.first;
  }

  /// 会员等级 id（rankcredits）
  final int memberLevel;

  /// 会员等级名称
  final String levelName;

  /// 成长值（等级列表中的起始积分）
  int get growthValue => currentRank?.currentrankstart ?? 0;

  /// 下一等级成长值（0 表示当前已是最高等级）
  int get nextLevelGrowthValue => currentRank?.currentrankend ?? 0;

  /// 未读消息数（用于头部消息图标红点角标；后端暂未提供字段，默认 0 不显示）
  final int unreadMessageCount;

  /// 会员等级到期时间（getranklist 的 expiredate，后端未返回时为 null）
  final DateTime? memberExpireDate;

  /// TODO(Mock): 天佑德值 —— 后端 MemberInfo / PointsAccount 暂无此字段，
  /// 当前使用标记 Mock 值用于 UI 还原，接入真实字段后替换。
  final int tianyoudeValue;

  const UserProfileState({
    this.nickname = '青轻用户_9527',
    this.avatarUrl,
    this.phoneMasked = '150****9999',
    required this.points,
    required this.couponCount,
    this.expiringPoints,
    this.expiringDate,
    this.gender = 0,
    this.genderName = '',
    this.birthday,
    this.address,
    this.ranks = const [],
    this.memberLevel = 0,
    this.levelName = '未登录',
    this.unreadMessageCount = 0,
    this.memberExpireDate,
    this.tianyoudeValue = 0,
  });

  /// 性别展示文本：1 / 2 直接映射男 / 女，其余取接口 gendername（如「未知」）
  String get genderText {
    switch (gender) {
      case 1:
        return '男';
      case 2:
        return '女';
      default:
        return genderName;
    }
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfileState>(() => UserProfileNotifier());

/// 用户 UID（真实接口 /api/sys/user/info 的 userrid），加载失败或未登录时为空串
final memberUidProvider = FutureProvider<String>((ref) async {
  final resp = await ref.read(authProvider.notifier).getCurrentUser();
  return resp.success ? (resp.data?.id ?? '') : '';
});

class UserProfileNotifier extends Notifier<UserProfileState> {
  @override
  UserProfileState build() {
    return const UserProfileState(points: 0, couponCount: 0);
  }

  /// 加载会员信息（真实接口）：
  ///   - 等级页签 / 成长值 / 等级名 / 到期时间：getRankList → POST /api/sys/app/getranklist
  ///   - 昵称 / 头像 / 手机号 / 当前等级 / 成长值：AuthRepository.getCurrentUser
  Future<void> load() async {
    final repository = ref.read(memberRepositoryProvider);
    try {
      final ranksResp = await repository.getRankList();
      final ranks = (ranksResp.success ? ranksResp.data!.ranks : const <RankBaseInfo>[]).where((e) => e.userrid > 0).toList();
      DateTime? expireDate;

      // 用户资料（昵称 / 头像 / 手机号 / 当前等级 / 成长值）
      String nickname = state.nickname;
      String? avatarUrl = state.avatarUrl;
      String phoneMasked = state.phoneMasked;
      int memberLevel = state.memberLevel;
      String levelName = state.levelName;
      int points = state.points;
      int? expiringPoints = state.expiringPoints;
      int gender = state.gender;
      String genderName = state.genderName;
      DateTime? birthday = state.birthday;
      String? address = state.address;

      final authResp = await ref.read(authProvider.notifier).getCurrentUser();
      if (authResp.success && authResp.data != null) {
        final UserInfo u = authResp.data!;
        nickname = u.nickname.isNotEmpty ? u.nickname : nickname;
        avatarUrl = u.avatarUrl ?? avatarUrl;
        phoneMasked = _maskPhone(u.phone);
        memberLevel = u.memberLevel;
        points = u.points;
        expiringPoints = u.expiringPoints;
        gender = u.gender;
        genderName = u.genderName;
        birthday = u.birthday;
        address = u.address ?? address;
      }
      // 重新匹配到期时间与等级名（此时 memberLevel 已更新为真实值）
      if (ranks.isNotEmpty) {
        final currentRank = ranks.firstWhere((e) => e.userrid == memberLevel, orElse: () => ranks.first);
        levelName = currentRank.userridname;
        expireDate = currentRank.expireDate;
      }

      state = UserProfileState(
        nickname: nickname,
        avatarUrl: avatarUrl,
        phoneMasked: phoneMasked,
        points: points,
        couponCount: 0,
        expiringPoints: expiringPoints,
        gender: gender,
        genderName: genderName,
        birthday: birthday,
        address: address,
        ranks: ranks,
        memberLevel: memberLevel,
        levelName: levelName,
        memberExpireDate: expireDate,
        // TODO(Mock): 天佑德值后端暂无对应字段，使用标记 Mock 值做 UI 还原
        tianyoudeValue: 1500,
      );
    } catch (e) {
      debugPrint('[UserProfile] load error: $e');
    }
  }

  /// 登出 / 注销时调用：重置为初始空状态，清除页面上的个人信息。
  void clear() {
    state = const UserProfileState(points: 0, couponCount: 0);
  }

  /// 手机号脱敏：130****9527
  static String _maskPhone(String? phone) {
    if (phone == null || phone.length < 7) return phone ?? '';
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }
}
