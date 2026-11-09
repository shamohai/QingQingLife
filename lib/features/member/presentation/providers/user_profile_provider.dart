import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/member_rank_models.dart';

import '../../../../core/network/api_response.dart';
import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/domain/repositories/auth_repository.dart' show UserInfo;

class UserProfileState {
  final String nickname;
  final String? avatarUrl;
  final String phoneMasked;
  final int points;

  /// 已领取卡券总数（availablewelfarelist.keepcount）。
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

  /// 当前会员等级图标（getmyprofile rankinfo.iconurl）
  final String levelIconUrl;

  /// 成长值（等级列表中的起始积分）
  int get growthValue => currentRank?.currentrankstart ?? 0;

  /// 下一等级成长值（0 表示当前已是最高等级）
  int get nextLevelGrowthValue => currentRank?.currentrankend ?? 0;

  /// 未读消息总数（头部消息入口角标）。
  ///
  /// 来源：getnotificationtypestat 中 type = -1（全部）项的 unreadcount；
  /// 进入「我的」页面时随资料加载/刷新拉取，接口失败或无「全部」项时保持现值（默认 0 不显示）。
  final int unreadMessageCount;

  /// 头像上传成功后的本地预览字节。
  ///
  /// 头像接口不返回新地址，部分 CDN 还会继续命中旧 URL 的图片缓存；
  /// 保留本次选择的图片可让所有已打开的头像区域立即显示新头像。
  final Uint8List? avatarPreviewBytes;

  /// 会员等级到期时间（getranklist 的 expiredate，后端未返回时为 null）
  final DateTime? memberExpireDate;

  /// TODO(Mock): 天佑德值 —— 后端 MemberInfo / PointsAccount 暂无此字段，
  /// 当前使用标记 Mock 值用于 UI 还原，接入真实字段后替换。
  final int tianyoudeValue;

  /// 资料是否正在加载。
  ///
  /// 不能再用 `levelName == '未登录'` 判断加载态：退出登录后资料也会被清空，
  /// 两者混用会让页面在退出后一直转圈。
  final bool isLoading;

  /// 是否已经完成过一次加载（成功或失败）。
  ///
  /// 首屏只有在真正请求资料时才展示加载态；未登录时应直接展示空态页面。
  final bool hasLoaded;

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
    this.levelIconUrl = '',
    this.unreadMessageCount = 0,
    this.avatarPreviewBytes,
    this.memberExpireDate,
    this.tianyoudeValue = 0,
    this.isLoading = false,
    this.hasLoaded = false,
  });

  UserProfileState withCouponCount(int couponCount) {
    return _copyWith(couponCount: couponCount);
  }

  UserProfileState withUnreadMessageCount(int unreadMessageCount) {
    return _copyWith(unreadMessageCount: unreadMessageCount);
  }

  UserProfileState withAvatarPreview(Uint8List bytes) {
    return _copyWith(avatarPreviewBytes: bytes);
  }

  UserProfileState withAvatarUrl(String url) {
    return _copyWith(avatarUrl: url);
  }

  UserProfileState withLoading(bool isLoading) {
    return _copyWith(isLoading: isLoading);
  }

  UserProfileState withLoadFinished() {
    return _copyWith(isLoading: false, hasLoaded: true);
  }

  UserProfileState _copyWith({int? couponCount, int? unreadMessageCount, String? avatarUrl, Uint8List? avatarPreviewBytes, bool? isLoading, bool? hasLoaded}) {
    return UserProfileState(
      nickname: nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneMasked: phoneMasked,
      points: points,
      couponCount: couponCount ?? this.couponCount,
      expiringPoints: expiringPoints,
      expiringDate: expiringDate,
      gender: gender,
      genderName: genderName,
      birthday: birthday,
      address: address,
      ranks: ranks,
      memberLevel: memberLevel,
      levelName: levelName,
      levelIconUrl: levelIconUrl,
      unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
      avatarPreviewBytes: avatarPreviewBytes ?? this.avatarPreviewBytes,
      memberExpireDate: memberExpireDate,
      tianyoudeValue: tianyoudeValue,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }

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
  int _loadGeneration = 0;

  @override
  UserProfileState build() {
    return const UserProfileState(points: 0, couponCount: 0);
  }

  /// 加载会员信息（真实接口）：
  ///   - 等级页签 / 成长值 / 等级名 / 到期时间：getRankList → POST /api/sys/app/getranklist
  ///   - 昵称 / 头像 / 手机号 / 当前等级 / 成长值：AuthRepository.getCurrentUser
  Future<void> load() async {
    if (!_isAuthenticated) {
      clear();
      return;
    }
    if (state.isLoading) return;

    final generation = ++_loadGeneration;
    state = state.withLoading(true);
    final repository = ref.read(memberRepositoryProvider);
    final couponCountFuture = _loadCouponCount();
    // 未读消息总数与资料并行拉取，失败不影响资料展示
    final unreadCountFuture = _loadUnreadMessageCount();
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
      String levelIconUrl = state.levelIconUrl;
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
        levelIconUrl = u.levelIconUrl.isNotEmpty ? u.levelIconUrl : levelIconUrl;
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
      final couponCount = await couponCountFuture ?? state.couponCount;

      final unreadMessageCount = await unreadCountFuture ?? state.unreadMessageCount;
      if (!_isCurrentLoad(generation)) return;
      state = UserProfileState(
        nickname: nickname,
        avatarUrl: avatarUrl,
        phoneMasked: phoneMasked,
        points: points,
        couponCount: couponCount,
        expiringPoints: expiringPoints,
        gender: gender,
        genderName: genderName,
        birthday: birthday,
        address: address,
        ranks: ranks,
        memberLevel: memberLevel,
        levelName: levelName,
        levelIconUrl: levelIconUrl,
        unreadMessageCount: unreadMessageCount,
        avatarPreviewBytes: state.avatarPreviewBytes,
        memberExpireDate: expireDate,
        // TODO(Mock): 天佑德值后端暂无对应字段，使用标记 Mock 值做 UI 还原
        tianyoudeValue: 1500,
        hasLoaded: true,
      );
    } catch (e) {
      debugPrint('[UserProfile] load error: $e');
      if (_isCurrentLoad(generation)) {
        state = state.withLoadFinished();
      }
    }
  }

  Future<int?> _loadCouponCount() async {
    try {
      final response = await ref.read(memberRepositoryProvider).getAvailableWelfareList(cardOnly: true);
      if (response.success && response.data != null) return response.data!.keepCount;
    } catch (error) {
      debugPrint('[UserProfile] coupon count error: $error');
    }
    return null;
  }

  /// 未读消息总数：getnotificationtypestat 中 type = -1（全部）项的 unreadcount。
  ///
  /// 接口未返回「全部」项或请求失败时返回 null，调用方保持现值。
  Future<int?> _loadUnreadMessageCount() async {
    try {
      final response = await ref.read(notificationRepositoryProvider).getTypeStats();
      if (!response.success || response.data == null) return null;
      for (final stat in response.data!) {
        // 接口约定 type = -1 为「全部」
        if (stat.typeValue == -1) return stat.unreadCount;
      }
    } catch (error) {
      debugPrint('[UserProfile] unread message count error: $error');
    }
    return null;
  }

  /// 上传新头像并在成功后刷新当前用户资料。
  ///
  /// 返回 null 表示上传成功；否则返回可直接展示给用户的错误文案。
  Future<String?> changeAvatar({required Uint8List bytes, required String ext}) async {
    final ApiResponse<void> response;
    try {
      response = await ref.read(memberRepositoryProvider).changeUserAvatar(buffer: bytes, ext: ext);
    } on NetworkException catch (error) {
      return error.toDisplayMessage(fallback: '头像更新失败，请稍后重试');
    } catch (error) {
      debugPrint('[UserProfile] change avatar error: $error');
      return '头像更新失败，请稍后重试';
    }

    if (!response.success) {
      final message = response.message.trim();
      return message.isEmpty || message == 'unknown error' ? '头像更新失败，请稍后重试' : message;
    }

    state = state.withAvatarPreview(bytes);
    try {
      final authResponse = await ref.read(authProvider.notifier).getCurrentUser();
      final avatarUrl = authResponse.data?.avatarUrl;
      if (authResponse.success && avatarUrl != null) {
        state = state.withAvatarUrl(avatarUrl);
      }
    } catch (error) {
      debugPrint('[UserProfile] avatar uploaded but profile refresh failed: $error');
    }
    return null;
  }

  /// 已加载用户资料后，进入「我的」页面时单独刷新卡券总数。
  Future<void> refreshCouponCount() async {
    if (!_isAuthenticated) return;
    final generation = _loadGeneration;
    final couponCount = await _loadCouponCount();
    if (couponCount != null && _isCurrentLoad(generation)) {
      state = state.withCouponCount(couponCount);
    }
  }

  /// 已加载用户资料后，进入「我的」页面时单独刷新未读消息总数（头部消息入口角标）。
  Future<void> refreshUnreadMessageCount() async {
    if (!_isAuthenticated) return;
    final generation = _loadGeneration;
    final unreadCount = await _loadUnreadMessageCount();
    if (unreadCount != null && _isCurrentLoad(generation)) {
      state = state.withUnreadMessageCount(unreadCount);
    }
  }

  /// 本地清零未读消息角标（通知列表页一键全部已读成功后同步调用）。
  void clearUnreadMessageCount() {
    if (state.unreadMessageCount == 0) return;
    state = state.withUnreadMessageCount(0);
  }

  /// 登出 / 注销时调用：重置为初始空状态，清除页面上的个人信息。
  void clear() {
    // 使仍在途的资料请求失效，避免退出后旧响应又把个人信息写回来。
    _loadGeneration++;
    state = const UserProfileState(points: 0, couponCount: 0);
  }

  bool get _isAuthenticated => ref.read(sessionProvider) == SessionState.authenticated;

  bool _isCurrentLoad(int generation) {
    return ref.mounted && generation == _loadGeneration && _isAuthenticated;
  }

  /// 手机号脱敏：130****9527
  static String _maskPhone(String? phone) {
    if (phone == null || phone.length < 7) return phone ?? '';
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }
}
