import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../domain/repositories/member_repository.dart';
import '../../domain/repositories/member_sign_in_repository.dart';
import '../models/available_welfare_model.dart';
import '../models/cash_coupon_model.dart';
import '../models/cash_coupon_share_model.dart';
import '../models/coupon_group_model.dart';
import '../models/member_authority_model.dart';
import '../models/member_rank_models.dart';
import '../models/member_sign_in_models.dart';
import '../models/service_coupon_model.dart';

/// 统一会员数据源（实现 MemberRepository 与 MemberSignInRepository 接口）
class MemberDataSource implements MemberRepository, MemberSignInRepository {
  final ApiClient? _apiClient;

  MemberDataSource({this._apiClient});

  // ── 会员等级列表 ──────────────────────────────────────────────────────────
  @override
  Future<ApiResponse<GetRankListResp>> getRankList() async {
    final client = _apiClient;
    if (client != null) {
      try {
        final response = await client.post<GetRankListResp>(
          '/api/sys/app/getranklist',
          data: const <String, dynamic>{},
          fromJson: (dynamic json) => GetRankListResp.fromJson(json as Map<String, dynamic>),
        );
        if (response.success) return response;
      } catch (_) {}
    }
    return ApiResponse.success(const GetRankListResp(ranks: _mockRanks));
  }

  // ── 会员等级明细 ──────────────────────────────────────────────────────────
  @override
  Future<ApiResponse<GetRankDetailResp>> getRankDetail({required int level}) async {
    final client = _apiClient;
    if (client != null) {
      try {
        final response = await client.post<GetRankDetailResp>(
          '/api/sys/app/getrankdetail',
          data: <String, dynamic>{'userrid': level},
          fromJson: (dynamic json) => GetRankDetailResp.fromJson(json as Map<String, dynamic>),
        );
        if (response.success) return response;
      } catch (_) {}
    }
    final index = (level - 1).clamp(0, _mockRanks.length - 1);
    final rank = _mockRanks[index];
    return ApiResponse.success(GetRankDetailResp(monthlyproductlist: _mockMonthlyProducts, rankbaseinfo: rank, services: []));
  }

  @override
  Future<ApiResponse<ReceiveUserServiceResult>> receiveUserService({required int serviceId}) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<ReceiveUserServiceResult>(
        '/api/sys/app/receiveuserservice',
        data: <String, dynamic>{'serviceid': serviceId},
        fromJson: (dynamic json) => ReceiveUserServiceResult.fromJson(json as Map<String, dynamic>),
      );
    }
    return ApiResponse.error('权益领取接口未配置');
  }

  @override
  Future<ApiResponse<CompleteUserInfoResult>> completeUserInfo({required String username, required int gender, required DateTime birthday}) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<CompleteUserInfoResult>(
        '/api/sys/v2/completeuserinfo',
        data: <String, dynamic>{
          'birthday': birthday.toIso8601String(),
          'gender': gender,
          'username': username,
        },
        fromJson: (dynamic json) => CompleteUserInfoResult.fromJson(json as Map<String, dynamic>),
      );
    }
    return ApiResponse.error('用户资料接口未配置');
  }

  @override
  Future<ApiResponse<void>> changeUserAvatar({required Uint8List buffer, required String ext}) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<void>('/api/sys/changeuseravatar', data: <String, dynamic>{'buffer': base64Encode(buffer), 'ext': ext});
    }
    return const ApiResponse<void>(code: 0, message: 'success', data: null, success: true);
  }

  // ── 地址能力 ─────────────────────────────────────────────────────────────
  @override
  Future<ApiResponse<List<MemberAddress>>> getAddresses({int addressId = 0}) async {
    final client = _apiClient;
    if (client != null) {
      try {
        final response = await client.post<List<MemberAddress>>(
          '/api/sys/getuseraddresslist',
          data: <String, dynamic>{'addressid': addressId},
          fromJson: (dynamic json) {
            final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
            final rawList = map['addresslist'];
            if (rawList is! List) return const <MemberAddress>[];
            return rawList.whereType<Map>().map(MemberAddress.fromApiJson).toList(growable: false);
          },
        );
        if (response.success) return response;
      } catch (_) {}
    }
    return ApiResponse.success(List.of(_addresses));
  }

  @override
  Future<ApiResponse<List<MemberArea>>> getAreaList({int parentId = 0, int? level}) async {
    final client = _apiClient;
    if (client != null) {
      try {
        final response = await client.post<List<MemberArea>>(
          '/api/common/getarealist',
          data: <String, dynamic>{'parentid': parentId, 'level': level},
          fromJson: (dynamic json) {
            final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};
            final rawList = map['arealist'];
            if (rawList is! List) return const <MemberArea>[];
            return rawList.whereType<Map>().map(MemberArea.fromJson).where((area) => area.id > 0 && area.name.isNotEmpty).toList(growable: false);
          },
        );
        if (response.success) return response;
      } catch (_) {}
    }
    final areas = _mockAreas.where((area) => area.parentId == parentId && (level == null || area.level == level)).toList(growable: false);
    return ApiResponse.success(areas);
  }

  @override
  Future<ApiResponse<MemberAddress>> saveAddress(MemberAddress address) async {
    final client = _apiClient;
    if (client != null) {
      try {
        final response = await client.post<MemberAddress>(
          '/api/sys/setuseraddress',
          data: <String, dynamic>{
            'id': int.tryParse(address.id ?? '') ?? 0,
            'consignee': address.name,
            'mobile': address.phone,
            'address': address.detail,
            'isdefult': address.isDefault,
          },
          fromJson: (dynamic json) {
            final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
            final addressInfo = map['addressinfo'];
            if (addressInfo is Map) {
              return MemberAddress.fromApiJson(addressInfo);
            }
            return address.copyWith(id: map['addressid']?.toString() ?? address.id);
          },
        );
        if (response.success) return response;
      } catch (_) {}
    }
    if (address.id == null) {
      final created = address.copyWith(id: 'addr_${_addressIdSeq++}');
      _addresses.add(created);
      return ApiResponse.success(created);
    }
    final index = _addresses.indexWhere((e) => e.id == address.id);
    if (index >= 0) _addresses[index] = address;
    return ApiResponse.success(address);
  }

  @override
  Future<ApiResponse<void>> deleteAddress(String addressId) async {
    _addresses.removeWhere((e) => e.id == addressId);
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> setDefaultAddress(String addressId) async {
    for (var i = 0; i < _addresses.length; i++) {
      final item = _addresses[i];
      _addresses[i] = item.copyWith(isDefault: item.id == addressId);
    }
    return ApiResponse.success(null);
  }

  // ── 会员卡权益与优惠券 ────────────────────────────────────────────────────
  @override
  Future<ApiResponse<MemberAuthorityModel>> getMemberAuthority({required int level}) async {
    final client = _apiClient;
    if (client != null) {
      try {
        final response = await client.post<Map<String, dynamic>>('/api/sys/v2/getmemberauthority', data: {'level': level});
        if (response.success && response.data != null) {
          return ApiResponse.success(MemberAuthorityModel.fromJson(response.data!));
        }
      } catch (_) {}
    }
    return ApiResponse.success(MemberAuthorityModel(level: level, auths: []));
  }

  @override
  Future<ApiResponse<CouponGroupListResult>> getCouponGroupList({required CouponGroupStatus status}) async {
    final client = _apiClient;
    if (client != null) {
      try {
        final response = await client.post<CouponGroupListResult>(
          '/api/promotion/getcoupongrouplist',
          data: <String, dynamic>{'status': status.apiValue, 'groupid': 0, 'receivecrmcoupon': false, 'receivewelfare': false},
          fromJson: (dynamic json) => CouponGroupListResult.fromJson(json as Map<String, dynamic>),
        );
        if (response.success) return response;
      } catch (_) {}
    }
    return ApiResponse.success(const CouponGroupListResult(coupons: [], totalCount: 0));
  }

  @override
  Future<ApiResponse<CashCouponListResult>> getCashCouponList({required CashCouponStatus status, required int pageIndex, required int pageSize}) async {
    final client = _apiClient;
    if (client != null) {
      try {
        final response = await client.post<CashCouponListResult>(
          '/api/promotion/getcashcouponlist',
          data: <String, dynamic>{'status': status.apiValue, 'pageindex': pageIndex, 'pagesize': pageSize},
          fromJson: (dynamic json) => CashCouponListResult.fromJson(json as Map<String, dynamic>),
        );
        if (response.success) return response;
      } catch (_) {}
    }
    return ApiResponse.success(const CashCouponListResult(coupons: [], totalCount: 0, hasMore: false));
  }

  @override
  Future<ApiResponse<CashCouponDetailResult>> getCashCouponDetail({required String couponSn}) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<CashCouponDetailResult>(
        '/api/promotion/getcashcoupondetail',
        data: <String, dynamic>{'couponsn': couponSn},
        fromJson: (dynamic json) => CashCouponDetailResult.fromJson(json as Map<String, dynamic>),
      );
    }
    return ApiResponse.success(const CashCouponDetailResult());
  }

  @override
  Future<ApiResponse<AvailableWelfareListResult>> getAvailableWelfareList({required bool cardOnly}) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<AvailableWelfareListResult>(
        '/api/promotion/availablewelfarelist',
        data: <String, dynamic>{'cardonly': cardOnly},
        fromJson: (dynamic json) => AvailableWelfareListResult.fromJson(json as Map<String, dynamic>),
      );
    }
    return ApiResponse.success(const AvailableWelfareListResult(welfareList: [], totalCount: 0, keepCount: 0));
  }

  @override
  Future<ApiResponse<BeginCashCouponShareResult>> beginCashCouponShare({required int userServiceId, required int cashCouponConfigId}) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<BeginCashCouponShareResult>(
        '/api/promotion/cashcoupons/begincashcouponshare',
        data: <String, dynamic>{'userserviceid': userServiceId, 'cashcouponconfigid': cashCouponConfigId},
        fromJson: (dynamic json) => BeginCashCouponShareResult.fromJson(json as Map<String, dynamic>),
      );
    }
    return ApiResponse.error('分享接口未配置');
  }

  @override
  Future<ApiResponse<ReceiveCashCouponFromShareResult>> receiveCashCouponFromShare({required String shareCode, required bool doReceive}) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<ReceiveCashCouponFromShareResult>(
        '/api/promotion/cashcoupons/recvcashcouponfromshare',
        data: <String, dynamic>{'dorecv': doReceive, 'sharecode': shareCode},
        fromJson: (dynamic json) => ReceiveCashCouponFromShareResult.fromJson(json as Map<String, dynamic>),
      );
    }
    return ApiResponse.error('领取接口未配置');
  }

  @override
  Future<ApiResponse<ServiceCouponListResult>> getServiceCouponList({required ServiceCouponStatus status, bool selfSetOnly = false}) async {
    final client = _apiClient;
    if (client != null) {
      try {
        final response = await client.post<ServiceCouponListResult>(
          '/api/promotion/getservicecouponlist',
          data: <String, dynamic>{'status': status.apiValue, 'selfsetonly': selfSetOnly},
          fromJson: (dynamic json) => ServiceCouponListResult.fromJson(json as Map<String, dynamic>),
        );
        if (response.success) return response;
      } catch (_) {}
    }
    return ApiResponse.success(const ServiceCouponListResult(coupons: []));
  }

  @override
  Future<ApiResponse<ServiceCouponInfoResult>> refreshServiceCouponInfoV2({required int couponTypeId, required int count, String? preferCouponSn}) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<ServiceCouponInfoResult>(
        '/api/promotion/v2/refreshservicecouponinfov2',
        data: <String, dynamic>{'userid': null, 'coupontypeid': couponTypeId, 'count': count, 'perfercouponsn': preferCouponSn},
        fromJson: (dynamic json) => ServiceCouponInfoResult.fromJson(json as Map<String, dynamic>),
      );
    }
    return ApiResponse.success(const ServiceCouponInfoResult());
  }

  @override
  Future<ApiResponse<GiveServiceCouponResult>> giveServiceCoupon({required int serviceCouponId, required int count}) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<GiveServiceCouponResult>(
        '/api/promotion/giveservicecoupon',
        data: <String, dynamic>{'serviceconponid': serviceCouponId, 'count': count},
        fromJson: (dynamic json) => GiveServiceCouponResult.fromJson(Map<String, dynamic>.from(json as Map)),
      );
    }
    return ApiResponse.success(GiveServiceCouponResult(shareGroup: 'share-$serviceCouponId-$count'));
  }

  @override
  Future<ApiResponse<void>> revokeServiceCoupon({required int serviceCouponId, required String shareGroup}) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<void>(
        '/api/promotion/giveservicecouponreovoke',
        data: <String, dynamic>{'serviceconponid': serviceCouponId, 'sharegroup': shareGroup},
      );
    }
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> receiveServiceCoupon({required String shareGroupId, int serviceCouponId = 0}) async {
    final client = _apiClient;
    if (client != null) {
      return client.post<void>(
        '/api/promotion/receiveservicecoupon',
        data: <String, dynamic>{'sharegroupid': shareGroupId, 'serviceconponid': serviceCouponId, 'dry': false},
      );
    }
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<MemberInfo>> getMemberInfo() async {
    return ApiResponse.success(
      const MemberInfo(
        id: '434543456576543',
        nickname: '青轻用户_9527',
        memberLevel: 2,
        levelName: '顾问级',
        growthValue: 778,
        nextLevelGrowthValue: 10000,
        points: 3580,
        availableCoupons: 5,
        hasHousekeeper: false,
      ),
    );
  }

  @override
  Future<ApiResponse<MemberLevelBenefits>> getLevelBenefits(int level) async {
    return ApiResponse.success(MemberLevelBenefits(level: level, name: '银卡会员', benefits: ['专享价', '免运费', '积分加速']));
  }

  @override
  Future<ApiResponse<CouponListResult>> getCoupons({required int page, required int pageSize, CouponStatus? status}) async {
    return ApiResponse.success(
      const CouponListResult(coupons: [], total: 0, page: 1, pageSize: 10, hasMore: false),
    );
  }

  @override
  Future<ApiResponse<void>> claimCoupon(String couponTemplateId) async {
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<PointsAccount>> getPointsAccount() async {
    return ApiResponse.success(
      PointsAccount(
        totalPoints: 3580,
        availablePoints: 3580,
        frozenPoints: 0,
        expiringPoints: 800,
        expiringDate: DateTime.now().add(const Duration(days: 90)),
        todayEarned: 10,
        totalEarned: 3580,
      ),
    );
  }

  @override
  Future<ApiResponse<PointsLogResult>> getPointsLogs({required int page, required int pageSize, PointsLogType? type}) async {
    return ApiResponse.success(const PointsLogResult(logs: [], total: 0, page: 1, pageSize: 10, hasMore: false));
  }

  @override
  Future<ApiResponse<String>> getPointsRules() async {
    return ApiResponse.success('积分规则说明...');
  }

  @override
  Future<ApiResponse<StatementResult>> getStatements({required int page, required int pageSize, StatementType? type}) async {
    return ApiResponse.success(const StatementResult(items: [], total: 0, page: 1, pageSize: 10, hasMore: false));
  }

  @override
  Future<ApiResponse<CustomerServiceInfo>> getCustomerService() async {
    return ApiResponse.success(const CustomerServiceInfo(phone: '400-800-8888', onlineUrl: 'https://example.com/service', workTime: '9:00-21:00'));
  }

  // ── MemberSignInRepository 签到能力 ─────────────────────────────────────
  @override
  Future<ApiResponse<MemberSignInOverview>> getSignInOverview() async {
    return ApiResponse.success(
      const MemberSignInOverview(
        points: 143544,
        consecutiveDays: 3,
        days: [],
        milestones: [],
        records: [],
        signedToday: true,
      ),
    );
  }

  @override
  Future<ApiResponse<MemberSignInResult>> signIn() async {
    return ApiResponse.success(const MemberSignInResult(signed: false, pointsEarned: 0, message: '今日已签到'));
  }

  static const List<RankBaseInfo> _mockRanks = [
    RankBaseInfo(userrid: 1, userridname: '人之德', currentrankstart: 0, currentrankend: 200),
    RankBaseInfo(userrid: 2, userridname: '家之德', currentrankstart: 200, currentrankend: 500),
    RankBaseInfo(userrid: 3, userridname: '国之德', currentrankstart: 500, currentrankend: 800),
    RankBaseInfo(userrid: 4, userridname: '天之德', currentrankstart: 800, currentrankend: 10000),
    RankBaseInfo(userrid: 5, userridname: '顾问级', currentrankstart: 10000, currentrankend: 0),
  ];

  static const List<ServiceProductItem> _mockMonthlyProducts = [
    ServiceProductItem(serviceid: 101, servicecode: 'MC1', productname: '399元券', servicedescr: '全场通用'),
    ServiceProductItem(serviceid: 102, servicecode: 'MC2', productname: '大额神券', servicedescr: '张张可叠加'),
  ];

  final List<MemberAddress> _addresses = [
    const MemberAddress(
      id: 'addr_1',
      name: '吴彦祖',
      phone: '13099876878',
      province: '甘肃省',
      city: '兰州市',
      district: '七里河区',
      detail: '建兰路街道兰州中心办公楼801室',
      isDefault: true,
    ),
  ];

  int _addressIdSeq = 2;

  static const List<MemberArea> _mockAreas = [
    MemberArea(id: 1, name: '甘肃省', level: 1, parentId: 0),
    MemberArea(id: 2, name: '兰州市', level: 2, parentId: 1),
    MemberArea(id: 4, name: '七里河区', level: 3, parentId: 2),
  ];
}

final memberDataSourceProvider = Provider<MemberDataSource>((ref) {
  return MemberDataSource(apiClient: ref.read(apiClientProvider));
});
