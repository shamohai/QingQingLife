import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/member_rank_models.dart';
import '../../data/models/member_authority_model.dart';
import 'user_profile_provider.dart';

/// 会员等级选项（由 getranklist 返回的 [RankBaseInfo] 映射而来）
class MemberLevelOption {
  /// 等级 id（RankBaseInfo.userrid，用于 getrankdetail 入参）
  final int id;

  /// 等级名（RankBaseInfo.userridname）
  final String name;

  /// 达到该等级所需成长值（RankBaseInfo.currentrankstart，卡片展示「成长值/该值升级」）
  final int growthThreshold;

  /// 下一等级起始积分（RankBaseInfo.currentrankend，等于 0 表示无上限）
  final int nextGrowthThreshold;

  /// 顶部卡片「可尊享 X 项会员权益」（由 getrankdetail 的权益条数回填）
  final int cardBenefitsCount;

  const MemberLevelOption({required this.id, required this.name, required this.growthThreshold, this.nextGrowthThreshold = 0, this.cardBenefitsCount = 0});

  MemberLevelOption copyWith({int? cardBenefitsCount}) {
    return MemberLevelOption(
      id: id,
      name: name,
      growthThreshold: growthThreshold,
      nextGrowthThreshold: nextGrowthThreshold,
      cardBenefitsCount: cardBenefitsCount ?? this.cardBenefitsCount,
    );
  }
}

/// 每月权益券（由 getrankdetail 的 monthlyproductlist 映射而来）
class MemberMonthlyCoupon {
  final String id;
  final String title;
  final String subtitle;

  /// 是否已领取（monthlyproductlist[].isreceived）
  final bool received;

  const MemberMonthlyCoupon({required this.id, required this.title, required this.subtitle, this.received = false});
}

/// 会员详情页状态
class MemberLevelState {
  /// 是否加载中
  final bool loading;

  /// 错误信息（非 null 表示加载失败）
  final String? errorMessage;

  /// 用户当前成长值（来源 getranklist，取当前等级的 currentrankstart）
  final int growthValue;

  /// 等级页签列表（getranklist）
  final List<MemberLevelOption> levels;

  /// 当前选中的等级页签
  final int selectedLevelIndex;

  /// 当前选中等级的权益明细原始数据（getrankdetail）
  final GetRankDetailResp? detail;

  /// 权益宫格数据（getrankdetail.services 过滤月度权益后映射）
  final List<MemberAuthItem> benefitAuths;

  /// 每月权益券列表
  final List<MemberMonthlyCoupon> monthlyCoupons;

  const MemberLevelState({
    this.loading = false,
    this.errorMessage,
    required this.growthValue,
    this.levels = const [],
    this.selectedLevelIndex = 0,
    this.detail,
    this.benefitAuths = const [],
    this.monthlyCoupons = const [],
  });

  /// 当前选中的等级（等级列表尚未加载完成时返回占位项，避免越界）
  MemberLevelOption get selectedLevel {
    if (levels.isEmpty) return const MemberLevelOption(id: 0, name: '', growthThreshold: 0);
    return levels[selectedLevelIndex.clamp(0, levels.length - 1)];
  }

  bool get hasError => errorMessage != null;

  /// 首次加载（尚无明细数据）时展示加载态；切换页签时保留旧内容、宫格区局部刷新
  bool get showGridLoading => loading && detail == null;
}

final memberLevelProvider = NotifierProvider<MemberLevelNotifier, MemberLevelState>(() => MemberLevelNotifier());

/// 会员详情页控制器
///
/// 数据链路：Page → [memberLevelProvider] → MemberRepository → MemberMixedDataSource
///   - 等级页签：getRankList()          → POST /api/sys/app/getranklist
///   - 等级权益：getRankDetail(level)   → POST /api/sys/app/getrankdetail
class MemberLevelNotifier extends Notifier<MemberLevelState> {
  @override
  MemberLevelState build() {
    return const MemberLevelState(growthValue: 0);
  }

  /// 加载等级列表（首次）+ 当前选中等级的权益明细
  Future<void> load() async {
    if (state.loading) return;

    state = _copy(loading: true);
    try {
      // 用户当前等级（rankcredits）：复用「我的」页已缓存的会员资料
      final profileState = ref.read(userProfileProvider);
      final currentLevelId = profileState.memberLevel;
      final repository = ref.read(memberRepositoryProvider);

      // ── 1) 等级列表（getranklist）─────────────────────────────
      var levels = state.levels;
      var index = state.selectedLevelIndex;
      int growthValue = state.growthValue;
      if (levels.isEmpty) {
        final listResp = await repository.getRankList();
        if (!listResp.success || listResp.data == null || listResp.data!.ranks.isEmpty) {
          state = _copy(loading: false, errorMessage: _friendlyMessage(listResp.message));
          return;
        }
        levels = listResp.data!.ranks.map(_toLevelOption).toList();
        // 首次进入默认选中用户当前等级（按 userrid 匹配），匹配不到则兜底为最高等级
        index = _matchCurrentLevelIndex(levels, currentLevelId);
        // 用户当前成长值：当前等级的起始积分
        growthValue = levels[index].growthThreshold;
      } else {
        index = index.clamp(0, levels.length - 1);
      }

      // ── 2) 当前等级权益明细（getrankdetail）──────────────────
      final levelId = levels[index].id;
      final detailResp = await repository.getRankDetail(level: levelId);
      if (!detailResp.success || detailResp.data == null) {
        state = _copy(loading: false, errorMessage: _friendlyMessage(detailResp.message), levels: levels, selectedLevelIndex: index, growthValue: growthValue);
        return;
      }

      final detail = detailResp.data!;
      final benefitAuths = _mapBenefitAuths(detail);
      final updatedLevels = [...levels];
      updatedLevels[index] = levels[index].copyWith(cardBenefitsCount: benefitAuths.length);

      state = _copy(
        loading: false,
        clearError: true,
        levels: updatedLevels,
        selectedLevelIndex: index,
        growthValue: growthValue,
        detail: detail,
        benefitAuths: benefitAuths,
        monthlyCoupons: _mapMonthlyCoupons(detail),
      );
    } catch (e) {
      debugPrint('[MemberLevel] load error: $e');
      state = _copy(loading: false, errorMessage: '会员权益加载失败，请稍后重试');
    }
  }

  /// 切换等级页签：更新选中项并按新等级重新拉取权益明细
  Future<void> selectLevel(int index) async {
    if (index < 0 || index >= state.levels.length || index == state.selectedLevelIndex) return;
    // 清空上一等级的明细/宫格/月度权益，避免切换瞬间展示其他等级的数据
    state = _copy(selectedLevelIndex: index, loading: false, clearError: true, clearDetail: true, clearBenefitAuths: true, monthlyCoupons: const []);
    await load();
  }

  // ── 映射：接口字段 → UI 模型 ───────────────────────────────

  /// RankBaseInfo → 等级页签选项
  MemberLevelOption _toLevelOption(RankBaseInfo rank) {
    return MemberLevelOption(id: rank.userrid, name: rank.userridname, growthThreshold: rank.currentrankstart, nextGrowthThreshold: rank.currentrankend);
  }

  /// 匹配用户当前等级所在的页签下标（找不到时兜底为最高等级）
  int _matchCurrentLevelIndex(List<MemberLevelOption> levels, int currentLevelId) {
    final idx = levels.indexWhere((e) => e.id == currentLevelId);
    return idx >= 0 ? idx : levels.length - 1;
  }

  /// getrankdetail.services → 权益宫格（排除月度权益，其余按接口顺序）
  List<MemberAuthItem> _mapBenefitAuths(GetRankDetailResp detail) {
    final items = <MemberAuthItem>[];
    for (final service in detail.services) {
      if (service.group == ServiceGroup.monthly) continue;
      items.add(
        MemberAuthItem(
          auth: service.serviceid,
          authname: service.servicename,
          introduce: service.description,
          isown: service.hasowned,
          isuse: false,
          tipsmsg: '',
          showimg: service.icon,
          newwelfare: false,
          sort: items.length + 1,
        ),
      );
    }
    return items;
  }

  /// getrankdetail → 每月权益券（优先 monthlyproductlist，回退 group=MONTHLY 的 services）
  List<MemberMonthlyCoupon> _mapMonthlyCoupons(GetRankDetailResp detail) {
    if (detail.monthlyproductlist.isNotEmpty) {
      return detail.monthlyproductlist
          .map((e) => MemberMonthlyCoupon(id: '${e.serviceid}', title: e.productname, subtitle: e.servicedescr, received: e.isreceived))
          .toList();
    }
    return detail.services
        .where((e) => e.group == ServiceGroup.monthly)
        .map((e) => MemberMonthlyCoupon(id: '${e.serviceid}', title: e.servicename, subtitle: e.description, received: e.hasowned))
        .toList();
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
    int? growthValue,
    List<MemberLevelOption>? levels,
    int? selectedLevelIndex,
    GetRankDetailResp? detail,
    bool clearDetail = false,
    List<MemberAuthItem>? benefitAuths,
    bool clearBenefitAuths = false,
    List<MemberMonthlyCoupon>? monthlyCoupons,
  }) {
    return MemberLevelState(
      loading: loading ?? state.loading,
      errorMessage: clearError ? null : (errorMessage ?? state.errorMessage),
      growthValue: growthValue ?? state.growthValue,
      levels: levels ?? state.levels,
      selectedLevelIndex: selectedLevelIndex ?? state.selectedLevelIndex,
      detail: clearDetail ? null : (detail ?? state.detail),
      benefitAuths: clearBenefitAuths ? const [] : (benefitAuths ?? state.benefitAuths),
      monthlyCoupons: monthlyCoupons ?? state.monthlyCoupons,
    );
  }
}
