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
/// 接口请求结果原样返回；尚未提供后端接口的方法返回 [ApiResponse.error]。
class MemberDataSource implements MemberRepository, MemberSignInRepository {
  final ApiClient apiClient;

  MemberDataSource({required this.apiClient});

  Future<ApiResponse<T>> _post<T>(String path, {dynamic data, T Function(dynamic)? fromJson}) {
    return apiClient.post<T>(path, data: data, fromJson: fromJson);
  }

  // ── 会员等级 ──────────────────────────────────────────────────────────────
  @override
  Future<ApiResponse<GetRankListResp>> getRankList() {
    return _post<GetRankListResp>(
      '/api/sys/app/getranklist',
      data: const <String, dynamic>{},
      fromJson: (dynamic json) => GetRankListResp.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<GetRankDetailResp>> getRankDetail({required int level}) {
    return _post<GetRankDetailResp>(
      '/api/sys/app/getrankdetail',
      data: <String, dynamic>{'userrid': level},
      fromJson: (dynamic json) => GetRankDetailResp.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<ReceiveUserServiceResult>> receiveUserService({required int serviceId}) {
    return _post<ReceiveUserServiceResult>(
      '/api/sys/app/receiveuserservice',
      data: <String, dynamic>{'serviceid': serviceId},
      fromJson: (dynamic json) => ReceiveUserServiceResult.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── 用户资料 ──────────────────────────────────────────────────────────────
  @override
  Future<ApiResponse<CompleteUserInfoResult>> completeUserInfo({required String username, required int gender, required DateTime birthday}) {
    return _post<CompleteUserInfoResult>(
      '/api/sys/v2/completeuserinfo',
      data: <String, dynamic>{'birthday': birthday.toIso8601String(), 'gender': gender, 'username': username},
      fromJson: (dynamic json) => CompleteUserInfoResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> changeUserAvatar({required Uint8List buffer, required String ext}) {
    return _post<void>('/api/sys/changeuseravatar', data: <String, dynamic>{'buffer': base64Encode(buffer), 'ext': ext});
  }

  // ── 收货地址 ──────────────────────────────────────────────────────────────
  @override
  Future<ApiResponse<List<MemberAddress>>> getAddresses({int addressId = 0}) {
    return _post<List<MemberAddress>>(
      '/api/sys/getuseraddresslist',
      data: <String, dynamic>{'addressid': addressId},
      fromJson: (dynamic json) {
        final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
        final rawList = map['addresslist'];
        if (rawList is! List) return const <MemberAddress>[];
        return rawList.whereType<Map>().map(MemberAddress.fromApiJson).toList(growable: false);
      },
    );
  }

  @override
  Future<ApiResponse<List<MemberArea>>> getAreaList({int parentId = 0, int? level}) {
    return _post<List<MemberArea>>(
      '/api/common/getarealist',
      data: <String, dynamic>{'parentid': parentId, 'level': level},
      fromJson: (dynamic json) {
        final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};
        final rawList = map['arealist'];
        if (rawList is! List) return const <MemberArea>[];
        return rawList.whereType<Map>().map(MemberArea.fromJson).where((area) => area.id > 0 && area.name.isNotEmpty).toList(growable: false);
      },
    );
  }

  @override
  Future<ApiResponse<MemberAddress>> saveAddress(MemberAddress address) {
    return _post<MemberAddress>(
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
  }

  @override
  Future<ApiResponse<void>> deleteAddress(String addressId) async => ApiResponse.error('');

  @override
  Future<ApiResponse<void>> setDefaultAddress(String addressId) async => ApiResponse.error('');

  // ── 会员权益与优惠券 ──────────────────────────────────────────────────────
  @override
  Future<ApiResponse<MemberAuthorityModel>> getMemberAuthority({required int level}) {
    return _post<MemberAuthorityModel>(
      '/api/sys/v2/getmemberauthority',
      data: <String, dynamic>{'level': level},
      fromJson: (dynamic json) => MemberAuthorityModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<CouponGroupListResult>> getCouponGroupList({required CouponGroupStatus status}) {
    return _post<CouponGroupListResult>(
      '/api/promotion/getcoupongrouplist',
      data: <String, dynamic>{'status': status.apiValue, 'groupid': 0, 'receivecrmcoupon': false, 'receivewelfare': false},
      fromJson: (dynamic json) => CouponGroupListResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<CashCouponListResult>> getCashCouponList({required CashCouponStatus status, required int pageIndex, required int pageSize}) {
    return _post<CashCouponListResult>(
      '/api/promotion/getcashcouponlist',
      data: <String, dynamic>{'status': status.apiValue, 'pageindex': pageIndex, 'pagesize': pageSize},
      fromJson: (dynamic json) => CashCouponListResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<CashCouponDetailResult>> getCashCouponDetail({required String couponSn}) {
    return _post<CashCouponDetailResult>(
      '/api/promotion/getcashcoupondetail',
      data: <String, dynamic>{'couponsn': couponSn},
      fromJson: (dynamic json) => CashCouponDetailResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<AvailableWelfareListResult>> getAvailableWelfareList({required bool cardOnly}) {
    return _post<AvailableWelfareListResult>(
      '/api/promotion/availablewelfarelist',
      data: <String, dynamic>{'cardonly': cardOnly},
      fromJson: (dynamic json) => AvailableWelfareListResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<BeginCashCouponShareResult>> beginCashCouponShare({required int userServiceId, required int cashCouponConfigId}) {
    return _post<BeginCashCouponShareResult>(
      '/api/promotion/cashcoupons/begincashcouponshare',
      data: <String, dynamic>{'userserviceid': userServiceId, 'cashcouponconfigid': cashCouponConfigId},
      fromJson: (dynamic json) => BeginCashCouponShareResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<ReceiveCashCouponFromShareResult>> receiveCashCouponFromShare({required String shareCode, required bool doReceive}) {
    return _post<ReceiveCashCouponFromShareResult>(
      '/api/promotion/cashcoupons/recvcashcouponfromshare',
      data: <String, dynamic>{'dorecv': doReceive, 'sharecode': shareCode},
      fromJson: (dynamic json) => ReceiveCashCouponFromShareResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<ServiceCouponListResult>> getServiceCouponList({required ServiceCouponStatus status, bool selfSetOnly = false}) {
    return _post<ServiceCouponListResult>(
      '/api/promotion/getservicecouponlist',
      data: <String, dynamic>{'status': status.apiValue, 'selfsetonly': selfSetOnly},
      fromJson: (dynamic json) => ServiceCouponListResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<ServiceCouponInfoResult>> refreshServiceCouponInfoV2({required int couponTypeId, required int count, String? preferCouponSn}) {
    return _post<ServiceCouponInfoResult>(
      '/api/promotion/v2/refreshservicecouponinfov2',
      data: <String, dynamic>{'userid': null, 'coupontypeid': couponTypeId, 'count': count, 'perfercouponsn': preferCouponSn},
      fromJson: (dynamic json) => ServiceCouponInfoResult.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<GiveServiceCouponResult>> giveServiceCoupon({required int serviceCouponId, required int count}) {
    return _post<GiveServiceCouponResult>(
      '/api/promotion/giveservicecoupon',
      data: <String, dynamic>{'serviceconponid': serviceCouponId, 'count': count},
      fromJson: (dynamic json) => GiveServiceCouponResult.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<void>> revokeServiceCoupon({required int serviceCouponId, required String shareGroup}) {
    return _post<void>('/api/promotion/giveservicecouponreovoke', data: <String, dynamic>{'serviceconponid': serviceCouponId, 'sharegroup': shareGroup});
  }

  @override
  Future<ApiResponse<void>> receiveServiceCoupon({required String shareGroupId, int serviceCouponId = 0}) {
    return _post<void>(
      '/api/promotion/receiveservicecoupon',
      data: <String, dynamic>{'sharegroupid': shareGroupId, 'serviceconponid': serviceCouponId, 'dry': false},
    );
  }

  // ── 客服 ──────────────────────────────────────────────────────────────────
  @override
  Future<ApiResponse<CustomerServiceInfo>> getCustomerService() {
    return _post<CustomerServiceInfo>(
      '/api/sys/app/getcustomermanagerinfo',
      data: const <String, dynamic>{},
      fromJson: (dynamic json) => CustomerServiceInfo.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  // ── 会员签到（后端接口暂未提供） ───────────────────────────────────────────
  @override
  Future<ApiResponse<MemberSignInOverview>> getSignInOverview() async => ApiResponse.error('');

  @override
  Future<ApiResponse<MemberSignInResult>> signIn() async => ApiResponse.error('');
}

final memberDataSourceProvider = Provider<MemberDataSource>((ref) {
  return MemberDataSource(apiClient: ref.read(apiClientProvider));
});
