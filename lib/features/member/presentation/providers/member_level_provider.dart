import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/member_authority_model.dart';
import '../../domain/repositories/member_repository.dart';
import 'user_profile_provider.dart';

/// 会员等级选项
///
/// TODO(Mock): 等级体系接口后端尚未提供，当前为本地 Mock
/// （设计稿等级：人之德/家之德/国之德/天之德/顾问级，默认选中顾问级）。
class MemberLevelOption {
  /// 等级名
  final String name;

  /// 达到该等级所需成长值（卡片展示「成长值/该值升级」）
  final int growthThreshold;

  /// 顶部卡片「可尊享 X 项会员权益」（顾问级为十项，与「我的」页一致）
  final int cardBenefitsCount;

  /// 会员权益宫格开放条数（对应接口 level = 页签序号 + 1）
  final int gridBenefitsCount;

  const MemberLevelOption({required this.name, required this.growthThreshold, required this.cardBenefitsCount, required this.gridBenefitsCount});
}

/// 每月权益券
///
/// TODO(Mock): 每月权益/领取接口后端尚未提供，当前为本地 Mock；
/// 后端就绪后补充 showimg（券面图）、领取状态等字段，券面替换为 AppNetworkImage。
class MemberMonthlyCoupon {
  final String id;
  final String title;
  final String subtitle;

  const MemberMonthlyCoupon({required this.id, required this.title, required this.subtitle});
}

/// 会员详情页状态
class MemberLevelState {
  /// 是否加载中
  final bool loading;

  /// 错误信息（非 null 表示加载失败）
  final String? errorMessage;

  /// 会员信息（用户当前成长值等，来源「我的」页全局状态）
  final MemberInfo memberInfo;

  /// 等级页签列表
  final List<MemberLevelOption> levels;

  /// 当前选中的等级页签
  final int selectedLevelIndex;

  /// 会员权益权限数据（当前由 MockMemberDataSource 提供；后端就绪后走 getmemberauthority）
  final MemberAuthorityModel? authority;

  /// 每月权益券列表
  final List<MemberMonthlyCoupon> monthlyCoupons;

  const MemberLevelState({
    this.loading = false,
    this.errorMessage,
    required this.memberInfo,
    required this.levels,
    this.selectedLevelIndex = 0,
    this.authority,
    required this.monthlyCoupons,
  });

  MemberLevelOption get selectedLevel => levels[selectedLevelIndex];

  bool get hasError => errorMessage != null;

  /// 首次加载（尚无数据）时展示加载态；切换页签时保留旧内容、宫格区局部刷新
  bool get showGridLoading => loading && authority == null;
}

final memberLevelProvider = NotifierProvider<MemberLevelNotifier, MemberLevelState>(() => MemberLevelNotifier());

/// 会员详情页控制器
///
/// 数据链路：Page → [memberLevelProvider] → MemberRepository → DataSource（当前为 Mock）
class MemberLevelNotifier extends Notifier<MemberLevelState> {
  /// 等级页签 Mock（设计稿：人之德/家之德/国之德/天之德/顾问级）
  static const List<MemberLevelOption> _mockLevels = [
    MemberLevelOption(name: '人之德', growthThreshold: 0, cardBenefitsCount: 2, gridBenefitsCount: 6),
    MemberLevelOption(name: '家之德', growthThreshold: 200, cardBenefitsCount: 4, gridBenefitsCount: 9),
    MemberLevelOption(name: '国之德', growthThreshold: 500, cardBenefitsCount: 6, gridBenefitsCount: 12),
    MemberLevelOption(name: '天之德', growthThreshold: 800, cardBenefitsCount: 8, gridBenefitsCount: 15),
    MemberLevelOption(name: '顾问级', growthThreshold: 10000, cardBenefitsCount: 10, gridBenefitsCount: 18),
  ];

  /// 每月权益券 Mock（对齐设计稿：399元券/大额神券/天佑德/视频会员等）
  static const List<MemberMonthlyCoupon> _mockCoupons = [
    MemberMonthlyCoupon(id: 'mc1', title: '399元券', subtitle: '全场通用'),
    MemberMonthlyCoupon(id: 'mc2', title: '大额神券', subtitle: '张张可叠加'),
    MemberMonthlyCoupon(id: 'mc3', title: '天佑德', subtitle: '品鉴装兑换'),
    MemberMonthlyCoupon(id: 'mc4', title: '咪咕视频', subtitle: '会员月卡'),
    MemberMonthlyCoupon(id: 'mc5', title: '腾讯视频', subtitle: '会员月卡'),
    MemberMonthlyCoupon(id: 'mc6', title: '爱奇艺', subtitle: '会员月卡'),
  ];

  @override
  MemberLevelState build() {
    return MemberLevelState(
      memberInfo: ref.read(userProfileProvider).memberInfo,
      levels: _mockLevels,
      // 默认选中「顾问级」（设计稿）
      selectedLevelIndex: _mockLevels.length - 1,
      monthlyCoupons: _mockCoupons,
    );
  }

  /// 加载当前选中等级的会员权益
  Future<void> load() async {
    if (state.loading) return;

    state = _copy(loading: true);
    try {
      var profile = ref.read(userProfileProvider);
      if (profile.memberInfo.memberLevel <= 0) {
        await ref.read(userProfileProvider.notifier).load();
        profile = ref.read(userProfileProvider);
      }

      // 等级参数：Mock 以页签序号 + 1 作为等级值（1~5）；真实接口就绪后按后端等级定义传值
      final level = state.selectedLevelIndex + 1;
      final resp = await ref.read(memberRepositoryProvider).getMemberAuthority(level: level);

      if (resp.success && resp.data != null) {
        state = _copy(loading: false, clearError: true, memberInfo: profile.memberInfo, authority: resp.data);
      } else {
        state = _copy(loading: false, errorMessage: _friendlyMessage(resp.message), memberInfo: profile.memberInfo);
      }
    } catch (e) {
      debugPrint('[MemberLevel] load error: $e');
      state = _copy(loading: false, errorMessage: '会员权益加载失败，请稍后重试');
    }
  }

  /// 切换等级页签：更新选中项并按新等级重新加载权益
  Future<void> selectLevel(int index) async {
    if (index < 0 || index >= state.levels.length || index == state.selectedLevelIndex) return;
    state = _copy(selectedLevelIndex: index, loading: false, clearError: true, clearAuthority: true);
    await load();
  }

  /// 后端 message 可能为空或为 `unknown error`，统一转成可展示的文案
  static String _friendlyMessage(String? raw) {
    final message = raw?.trim() ?? '';
    if (message.isEmpty || message == 'unknown error') return '会员权益加载失败，请稍后重试';
    return message;
  }

  MemberLevelState _copy({
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    MemberInfo? memberInfo,
    int? selectedLevelIndex,
    MemberAuthorityModel? authority,
    bool clearAuthority = false,
  }) {
    return MemberLevelState(
      loading: loading ?? state.loading,
      errorMessage: clearError ? null : (errorMessage ?? state.errorMessage),
      memberInfo: memberInfo ?? state.memberInfo,
      levels: state.levels,
      selectedLevelIndex: selectedLevelIndex ?? state.selectedLevelIndex,
      authority: clearAuthority ? null : (authority ?? state.authority),
      monthlyCoupons: state.monthlyCoupons,
    );
  }
}
