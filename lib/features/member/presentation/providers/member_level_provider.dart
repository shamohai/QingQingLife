import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qingqinglife/core/logging/app_logger.dart';

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

  /// 等级图标（RankBaseInfo.iconurl）
  final String iconUrl;

  const MemberLevelOption({
    required this.id,
    required this.name,
    required this.growthThreshold,
    this.nextGrowthThreshold = 0,
    this.cardBenefitsCount = 0,
    this.iconUrl = '',
  });

  MemberLevelOption copyWith({int? cardBenefitsCount, String? iconUrl}) {
    return MemberLevelOption(
      id: id,
      name: name,
      growthThreshold: growthThreshold,
      nextGrowthThreshold: nextGrowthThreshold,
      cardBenefitsCount: cardBenefitsCount ?? this.cardBenefitsCount,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }
}

/// 每月权益券（由 getrankdetail 的 monthlyproductlist 映射而来）
class MemberMonthlyCoupon {
  /// 对应 monthlyproductlist[].serviceid，用于领取接口 serviceid 参数。
  final int serviceId;
  final String serviceCode;
  final String productName;
  final String serviceDescr;
  final bool isReceived;
  final bool hasOwned;
  final bool hasReceived;
  final String instanceType;
  final String? receivedDate;
  final int productType;
  final int userServiceId;
  final int bailihuiType;
  final int pid;
  final String? productImg;

  const MemberMonthlyCoupon({
    required this.serviceId,
    this.serviceCode = '',
    this.productName = '',
    this.serviceDescr = '',
    this.isReceived = false,
    this.hasOwned = false,
    this.hasReceived = false,
    this.instanceType = '',
    this.receivedDate,
    this.productType = 0,
    this.userServiceId = 0,
    this.bailihuiType = 0,
    this.pid = 0,
    this.productImg,
  });

  MemberMonthlyCoupon copyWith({bool? isReceived, bool? hasReceived, int? userServiceId}) {
    return MemberMonthlyCoupon(
      serviceId: serviceId,
      serviceCode: serviceCode,
      productName: productName,
      serviceDescr: serviceDescr,
      isReceived: isReceived ?? this.isReceived,
      hasOwned: hasOwned,
      hasReceived: hasReceived ?? this.hasReceived,
      instanceType: instanceType,
      receivedDate: receivedDate,
      productType: productType,
      userServiceId: userServiceId ?? this.userServiceId,
      bailihuiType: bailihuiType,
      pid: pid,
      productImg: productImg,
    );
  }
}

/// 会员权益宫格项：保留接口原始服务信息，供领取后按 instancetype 分流。
class MemberBenefitItem {
  final MemberAuthItem auth;
  final SysServiceItem service;

  const MemberBenefitItem({required this.auth, required this.service});
}

/// 已完成用户权益领取、可进入具体业务页的权益信息。
class MemberBenefitAccess {
  final String instanceType;
  final int serviceId;
  final int userServiceId;
  final int productId;
  final ServiceBindInfo? bindInfo;

  const MemberBenefitAccess({required this.instanceType, required this.serviceId, required this.userServiceId, this.productId = 0, this.bindInfo});

  /// 权益商城权益对应的模板 id，来自权益详情 bindinfo.bindsharecartinfo。
  int get shareCartTemplateId => bindInfo?.bindsharecartinfo?.sharecarttemplateid ?? 0;
}

/// 点击权益后的处理结果。
class MemberBenefitUseResult {
  final bool success;
  final bool busy;
  final bool ignored;
  final String? message;
  final MemberBenefitAccess? access;

  const MemberBenefitUseResult._({required this.success, this.busy = false, this.ignored = false, this.message, this.access});

  const MemberBenefitUseResult.success(MemberBenefitAccess access, {String? message}) : this._(success: true, message: message, access: access);

  const MemberBenefitUseResult.failure(String message) : this._(success: false, message: message);

  const MemberBenefitUseResult.busy() : this._(success: false, busy: true);

  const MemberBenefitUseResult.ignored() : this._(success: true, ignored: true);
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
  final List<MemberBenefitItem> benefitAuths;

  /// 每月权益券列表
  final List<MemberMonthlyCoupon> monthlyCoupons;

  /// 正在提交领取请求的权益 id，用于防止重复点击。
  final Set<int> receivingServiceIds;

  const MemberLevelState({
    this.loading = false,
    this.errorMessage,
    required this.growthValue,
    this.levels = const [],
    this.selectedLevelIndex = 0,
    this.detail,
    this.benefitAuths = const [],
    this.monthlyCoupons = const [],
    this.receivingServiceIds = const {},
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
      final detailIconUrl = detail.rankbaseinfo?.iconUrl.trim() ?? '';
      updatedLevels[index] = levels[index].copyWith(cardBenefitsCount: benefitAuths.length, iconUrl: detailIconUrl.isEmpty ? null : detailIconUrl);

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
      AppLogger.error('load error', module: 'member_level', error: e);
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

  /// 月度权益仅在 hasowned=true 时处理；未领取先领取，再返回 instancetype 分流信息。
  Future<MemberBenefitUseResult> useMonthlyCoupon(MemberMonthlyCoupon coupon) async {
    AppLogger.debug('use monthly coupon: ${coupon.serviceId} (${coupon.productName})', module: 'member_level');
    if (!coupon.hasOwned) return const MemberBenefitUseResult.failure('暂无权限');

    final monthlyService = _findMonthlyService();
    final serviceId = coupon.serviceId > 0 ? coupon.serviceId : (state.detail?.monthlyserviceid ?? monthlyService?.serviceid ?? 0);
    if (serviceId <= 0) return const MemberBenefitUseResult.failure('权益信息无效，请刷新后重试');
    if (state.receivingServiceIds.contains(serviceId)) return const MemberBenefitUseResult.busy();

    var userServiceId = coupon.userServiceId > 0 ? coupon.userServiceId : (state.detail?.monthlyuserserviceid ?? monthlyService?.userserviceid ?? 0);
    String? message;

    if (!coupon.hasReceived) {
      state = _copy(receivingServiceIds: {...state.receivingServiceIds, serviceId});
      try {
        final response = await ref.read(memberRepositoryProvider).receiveUserService(serviceId: serviceId);
        if (!response.success || response.data == null) {
          return MemberBenefitUseResult.failure(_friendlyMessage(response.message, fallback: '领取失败，请稍后重试'));
        }

        final result = response.data!;
        if (result.userServiceId <= 0) {
          return const MemberBenefitUseResult.failure('领取成功但未返回用户权益信息，请刷新后重试');
        }

        userServiceId = result.userServiceId;
        message = result.isDuplicate ? '该权益已领取' : '领取成功';
        _markMonthlyCouponReceived(serviceId, userServiceId);
      } catch (e) {
        AppLogger.error('receive monthly coupon error', module: 'member_level', error: e);
        return const MemberBenefitUseResult.failure('领取失败，请稍后重试');
      } finally {
        final receiving = {...state.receivingServiceIds}..remove(serviceId);
        state = _copy(receivingServiceIds: receiving);
      }
    }

    return MemberBenefitUseResult.success(
      _buildBenefitAccess(
        serviceId: serviceId,
        userServiceId: userServiceId,
        productId: coupon.pid > 0 ? coupon.pid : _productIdOf(monthlyService),
        service: monthlyService,
      ),
      message: message,
    );
  }

  /// 会员权益仅在 hasowned=true 时处理；未领取先领取，再返回 instancetype 分流信息。
  ///
  /// 接口文档：POST /api/sys/app/receiveuserservice
  /// 请求：{ serviceid }
  /// 响应：{ userserviceid, isdup, datatag }
  Future<MemberBenefitUseResult> useBenefit(MemberBenefitItem item) async {
    final service = item.service;
    if (!service.hasowned) {
      return const MemberBenefitUseResult.failure('暂无权限');
    }
    if (service.serviceid <= 0) {
      return const MemberBenefitUseResult.failure('权益信息无效，请刷新后重试');
    }
    if (state.receivingServiceIds.contains(service.serviceid)) {
      return const MemberBenefitUseResult.busy();
    }

    var userServiceId = service.userserviceid ?? 0;
    String? message;

    if (!service.hasreceived) {
      state = _copy(receivingServiceIds: {...state.receivingServiceIds, service.serviceid});
      try {
        final response = await ref.read(memberRepositoryProvider).receiveUserService(serviceId: service.serviceid);
        if (!response.success || response.data == null) {
          return MemberBenefitUseResult.failure(_friendlyMessage(response.message, fallback: '领取失败，请稍后重试'));
        }

        final result = response.data!;
        if (result.userServiceId <= 0) {
          return const MemberBenefitUseResult.failure('领取成功但未返回用户权益信息，请刷新后重试');
        }

        userServiceId = result.userServiceId;
        message = result.isDuplicate ? '该权益已领取' : '领取成功';
        _markBenefitReceived(service.serviceid, userServiceId);
      } catch (e) {
        AppLogger.error('receive benefit error', module: 'member_level', error: e);
        return const MemberBenefitUseResult.failure('领取失败，请稍后重试');
      } finally {
        final receiving = {...state.receivingServiceIds}..remove(service.serviceid);
        state = _copy(receivingServiceIds: receiving);
      }
    }

    return MemberBenefitUseResult.success(
      _buildBenefitAccess(serviceId: service.serviceid, userServiceId: userServiceId, productId: _productIdOf(service), service: service),
      message: message,
    );
  }

  // ── 映射：接口字段 → UI 模型 ───────────────────────────────

  /// RankBaseInfo → 等级页签选项
  MemberLevelOption _toLevelOption(RankBaseInfo rank) {
    return MemberLevelOption(
      id: rank.userrid,
      name: rank.userridname,
      growthThreshold: rank.currentrankstart,
      nextGrowthThreshold: rank.currentrankend,
      iconUrl: rank.iconUrl,
    );
  }

  /// 匹配用户当前等级所在的页签下标（找不到时兜底为最高等级）
  int _matchCurrentLevelIndex(List<MemberLevelOption> levels, int currentLevelId) {
    final idx = levels.indexWhere((e) => e.id == currentLevelId);
    return idx >= 0 ? idx : levels.length - 1;
  }

  /// getrankdetail.services → 权益宫格（排除月度权益，其余按接口顺序）
  List<MemberBenefitItem> _mapBenefitAuths(GetRankDetailResp detail) {
    final items = <MemberBenefitItem>[];
    for (final service in detail.services) {
      if (service.group == ServiceGroup.monthly) continue;
      items.add(
        MemberBenefitItem(
          auth: MemberAuthItem(
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
          service: service,
        ),
      );
    }
    return items;
  }

  void _markBenefitReceived(int serviceId, int userServiceId) {
    final detail = state.detail;
    if (detail == null) return;

    final updatedServices = detail.services
        .map((service) => service.serviceid == serviceId ? service.copyWith(userserviceid: userServiceId, hasowned: true, hasreceived: true) : service)
        .toList();
    final updatedDetail = detail.copyWith(services: updatedServices);
    state = _copy(detail: updatedDetail, benefitAuths: _mapBenefitAuths(updatedDetail));
  }

  void _markMonthlyCouponReceived(int serviceId, int userServiceId) {
    final detail = state.detail;
    if (detail == null) return;

    final updatedServices = detail.services
        .map((service) => service.group == ServiceGroup.monthly ? service.copyWith(userserviceid: userServiceId, hasowned: true, hasreceived: true) : service)
        .toList();
    final updatedDetail = detail.copyWith(monthlyuserserviceid: userServiceId, services: updatedServices);
    final updatedCoupons = state.monthlyCoupons
        .map((item) => item.serviceId == serviceId ? item.copyWith(isReceived: true, hasReceived: true, userServiceId: userServiceId) : item)
        .toList();
    state = _copy(detail: updatedDetail, monthlyCoupons: updatedCoupons);
  }

  SysServiceItem? _findMonthlyService() {
    for (final service in state.detail?.services ?? const <SysServiceItem>[]) {
      if (service.group == ServiceGroup.monthly) return service;
    }
    return null;
  }

  MemberBenefitAccess _buildBenefitAccess({required int serviceId, required int userServiceId, required int productId, required SysServiceItem? service}) {
    return MemberBenefitAccess(
      instanceType: service?.instancetype ?? '',
      serviceId: serviceId,
      userServiceId: userServiceId,
      productId: productId,
      bindInfo: service?.bindinfo,
    );
  }

  int _productIdOf(SysServiceItem? service) {
    final products = service?.bindinfo?.bindproductlist;
    return products == null || products.isEmpty ? 0 : products.first.pid;
  }

  /// getrankdetail → 每月权益券（优先 monthlyproductlist，回退 group=MONTHLY 的 services）
  List<MemberMonthlyCoupon> _mapMonthlyCoupons(GetRankDetailResp detail) {
    final monthlyService = _monthlyServiceOf(detail);
    final monthlyServiceId = detail.monthlyserviceid ?? monthlyService?.serviceid ?? 0;
    final monthlyUserServiceId = detail.monthlyuserserviceid ?? monthlyService?.userserviceid;
    final monthlyReceived = (monthlyUserServiceId ?? 0) > 0;
    final monthlyHasOwned = monthlyService?.hasowned ?? false;
    final monthlyHasReceived = monthlyService?.hasreceived ?? monthlyReceived;
    final monthlyInstanceType = monthlyService?.instancetype ?? '';

    if (detail.monthlyproductlist.isNotEmpty) {
      return detail.monthlyproductlist
          .map(
            (e) => MemberMonthlyCoupon(
              serviceId: monthlyServiceId,
              serviceCode: e.servicecode,
              productName: e.productname,
              serviceDescr: e.servicedescr,
              isReceived: monthlyHasReceived || e.isreceived,
              hasOwned: monthlyHasOwned,
              hasReceived: monthlyHasReceived || e.isreceived,
              instanceType: monthlyInstanceType,
              receivedDate: e.receiveddate,
              productType: e.producttype,
              userServiceId: monthlyUserServiceId ?? e.userserviceid,
              bailihuiType: e.bailihuitype,
              pid: e.pid,
              productImg: e.productimg,
            ),
          )
          .toList();
    }
    return detail.services
        .where((e) => e.group == ServiceGroup.monthly)
        .map(
          (e) => MemberMonthlyCoupon(
            serviceId: e.serviceid,
            serviceCode: e.servicecode,
            productName: e.servicename,
            serviceDescr: e.description,
            isReceived: e.hasreceived,
            hasOwned: e.hasowned,
            hasReceived: e.hasreceived,
            instanceType: e.instancetype,
            userServiceId: monthlyUserServiceId ?? e.userserviceid ?? 0,
          ),
        )
        .toList();
  }

  SysServiceItem? _monthlyServiceOf(GetRankDetailResp detail) {
    for (final service in detail.services) {
      if (service.group == ServiceGroup.monthly) return service;
    }
    return null;
  }

  /// 后端 message 可能为空或为 `unknown error`，统一转成可展示的文案
  static String _friendlyMessage(String? raw, {String fallback = '会员权益加载失败，请稍后重试'}) {
    final message = raw?.trim() ?? '';
    if (message.isEmpty || message == 'unknown error') return fallback;
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
    List<MemberBenefitItem>? benefitAuths,
    bool clearBenefitAuths = false,
    List<MemberMonthlyCoupon>? monthlyCoupons,
    Set<int>? receivingServiceIds,
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
      receivingServiceIds: receivingServiceIds ?? state.receivingServiceIds,
    );
  }
}
