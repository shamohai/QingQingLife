import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../domain/repositories/member_repository.dart';
import '../models/available_welfare_model.dart';
import '../models/cash_coupon_model.dart';
import '../models/cash_coupon_share_model.dart';
import '../models/coupon_group_model.dart';
import '../models/service_coupon_model.dart';
import '../models/member_authority_model.dart';
import '../models/member_rank_models.dart';

/// 会员数据源（对接真实 API）
///
/// 所有接口均通过 [ApiClient] 发起，加密/签名由拦截器自动处理；
/// 请求公共参数 meta / authtoken 由拦截器统一注入，业务层不传。
class MemberRemoteDataSource {
  final ApiClient _apiClient;

  MemberRemoteDataSource(this._apiClient);

  /// 获取会员等级列表
  ///
  /// 接口：POST /api/sys/app/getranklist
  /// 请求体：无业务参数（authtoken 由拦截器注入）
  /// 响应：[ApiResponse<GetRankListResp>]
  ///   GetRankListResp {
  ///     ranks: [{ userrid, userridname, expiredate, currentrankstart, currentrankend }],
  ///     datatag
  ///   }
  ///
  /// 字段绑定：
  ///   userrid          → 等级 id（用于 getrankdetail 入参、匹配用户当前等级）
  ///   userridname      → 等级名称（页签文案）
  ///   currentrankstart → 达到该等级的起始积分（等级卡片「x/y 升级」的 y）
  ///   currentrankend   → 结束积分（等于 0 表示无上限）
  ///   expiredate       → 当前等级过期日期
  ///
  /// 使用示例：
  /// ```dart
  /// final resp = await ref.read(memberRemoteDataSourceProvider).getRankList();
  /// if (resp.success) {
  ///   final ranks = resp.data!.ranks; // RankBaseInfo 列表
  /// }
  /// ```
  Future<ApiResponse<GetRankListResp>> getRankList() async {
    return _apiClient.post<GetRankListResp>(
      '/api/sys/app/getranklist',
      data: const <String, dynamic>{},
      fromJson: (dynamic json) => GetRankListResp.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取指定等级的权益明细
  ///
  /// 接口：POST /api/sys/app/getrankdetail
  /// 请求体：{"userrid": <等级 id>}
  /// 响应：[ApiResponse<GetRankDetailResp>]
  ///   GetRankDetailResp {
  ///     monthlyproductlist: [{ serviceid, servicecode, productname, servicedescr,
  ///                            isreceived, receiveddate, producttype, userserviceid,
  ///                            bailihuitype, pid, productimg }],
  ///     rankbaseinfo: { userrid, userridname, expiredate, currentrankstart, currentrankend },
  ///     services: [{ serviceid, servicecode, servicename, instancetype, group,
  ///                  icon, hasowned, bindinfo }],
  ///     datatag
  ///   }
  ///
  /// 字段绑定：
  ///   services[].group        → GENERAL 普通权益（权益宫格）/ MONTHLY 月度权益 / BIRTHDAY 生日赠礼
  ///   services[].servicename  → 权益名称
  ///   services[].hasowned     → 是否已拥有
  ///   services[].bindinfo.*   → 权益说明（产品描述 / 服务券描述 / 权益商城描述 / 红包描述）
  ///   monthlyproductlist      → 每月权益券（productname 标题 + servicedescr 副标题，isreceived 领取状态）
  ///
  /// 使用示例：
  /// ```dart
  /// final resp = await ref.read(memberRemoteDataSourceProvider).getRankDetail(level: 5);
  /// if (resp.success) {
  ///   final detail = resp.data!;
  ///   final benefits = detail.services.where((s) => s.group != ServiceGroup.monthly);
  ///   final monthly = detail.monthlyproductlist;
  /// }
  /// ```
  Future<ApiResponse<GetRankDetailResp>> getRankDetail({required int level}) async {
    return _apiClient.post<GetRankDetailResp>(
      '/api/sys/app/getrankdetail',
      data: <String, dynamic>{'userrid': level},
      fromJson: (dynamic json) => GetRankDetailResp.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 领取用户权益，包括月度权益和生日赠礼。
  ///
  /// 接口：POST /api/sys/app/receiveuserservice
  /// 请求体：{"serviceid": <权益服务 id>}
  Future<ApiResponse<ReceiveUserServiceResult>> receiveUserService({required int serviceId}) async {
    return _apiClient.post<ReceiveUserServiceResult>(
      '/api/sys/app/receiveuserservice',
      data: <String, dynamic>{'serviceid': serviceId},
      fromJson: (dynamic json) => ReceiveUserServiceResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 补充/修改用户信息。
  ///
  /// 接口：POST /api/sys/v2/completeuserinfo
  /// 未在编辑页维护的扩展资料按接口约定传 null。
  Future<ApiResponse<CompleteUserInfoResult>> completeUserInfo({required String username, required int gender, required DateTime birthday}) async {
    return _apiClient.post<CompleteUserInfoResult>(
      '/api/sys/v2/completeuserinfo',
      data: <String, dynamic>{
        'birthday': birthday.toIso8601String(),
        'drinkrate': null,
        'buyintention': null,
        'scene': null,
        'gender': gender,
        'username': username,
        'realname': null,
        'hobby': null,
        'farmtask': false,
      },
      fromJson: (dynamic json) => CompleteUserInfoResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 更换当前用户头像。
  ///
  /// 接口：POST /api/sys/changeuseravatar
  /// 请求体：{"buffer": "<图片字节 base64>", "ext": "jpg"}
  /// 响应：{"result": 0, "descr": "", "datatag": "..."}
  Future<ApiResponse<void>> changeUserAvatar({required Uint8List buffer, required String ext}) async {
    return _apiClient.post<void>('/api/sys/changeuseravatar', data: <String, dynamic>{'buffer': base64Encode(buffer), 'ext': ext});
  }

  /// 获取当前用户的收货地址列表。
  ///
  /// 接口：POST /api/sys/getuseraddresslist
  /// 请求体：{"addressid": 0}（0 表示返回全部地址，-1 默认返回 1 条/默认地址）
  /// 响应：{addresslist: [{id, consignee, provincename, cityname,
  /// countyname, address, isdefult, phone, mobile, ...}], datatag}
  Future<ApiResponse<List<MemberAddress>>> getAddresses({int addressId = 0}) async {
    return _apiClient.post<List<MemberAddress>>(
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

  /// 获取省市区列表。
  ///
  /// 接口：POST /api/common/getarealist
  /// 请求体：{"parentid": 0, "level": 1}（parentid=0 默认获取全部）
  /// 响应：{arealist: [{id, name, level, parentid}], datatag}
  Future<ApiResponse<List<MemberArea>>> getAreaList({int parentId = 0, int? level}) async {
    return _apiClient.post<List<MemberArea>>(
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

  /// 添加或更新用户收货地址。
  ///
  /// 接口：POST /api/sys/setuseraddress
  /// [address.areaId] 为空时，根据省、市、区名称调用区域查询接口获取末级区域 ID。
  Future<ApiResponse<MemberAddress>> saveAddress(MemberAddress address) async {
    final areaId = await _resolveAreaId(address);
    if (areaId == null) {
      return ApiResponse.error('无法获取所选地区信息，请重新选择所在地区');
    }

    final response = await _apiClient.post<MemberAddress>(
      '/api/sys/setuseraddress',
      data: <String, dynamic>{
        'id': int.tryParse(address.id ?? '') ?? 0,
        'areaid': areaId,
        'consignee': address.name,
        'mobile': address.phone,
        'address': address.detail,
        'isdefult': address.isDefault,
        'isdelete': false,
      },
      fromJson: (dynamic json) {
        final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
        final addressInfo = map['addressinfo'];
        if (addressInfo is Map) {
          return MemberAddress.fromApiJson(addressInfo);
        }
        final returnedId = map['addressid']?.toString();
        return address.copyWith(id: returnedId ?? address.id, areaId: areaId);
      },
    );
    return response;
  }

  Future<int?> _resolveAreaId(MemberAddress address) async {
    if (address.areaId != null && address.areaId! > 0) return address.areaId;
    final response = await _apiClient.post<_AreaInfo>(
      '/api/common/getareainfobyname',
      data: <String, dynamic>{'provincename': address.province, 'cityname': address.city, 'districtname': address.district},
      fromJson: (dynamic json) => _AreaInfo.fromJson(json as Map<String, dynamic>),
    );
    return response.success ? response.data?.districtId : null;
  }

  /// 获取会员权益权限
  ///
  /// 接口：POST /api/sys/v2/getmemberauthority
  /// 请求体：{"level": <会员等级>}
  /// 响应：[ApiResponse<MemberAuthorityModel>]
  ///
  /// 使用示例：
  /// ```dart
  /// final dataSource = ref.read(memberRemoteDataSourceProvider);
  /// final resp = await dataSource.getMemberAuthority(level: 1);
  /// if (resp.success) {
  ///   final auths = resp.data!.auths;
  ///   final hasPrivilege = auths.any((a) => a.isown);
  /// }
  /// ```
  Future<ApiResponse<MemberAuthorityModel>> getMemberAuthority({required int level}) async {
    final response = await _apiClient.post<Map<String, dynamic>>('/api/sys/v2/getmemberauthority', data: {'level': level});
    if (response.success && response.data != null) {
      return ApiResponse.success(MemberAuthorityModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, code: response.code);
  }

  /// 获取我的优惠券分组列表。
  ///
  /// 接口：POST /api/promotion/getcoupongrouplist
  /// 请求体：{status, groupid: 0, receivecrmcoupon: false, receivewelfare: false}
  /// 状态：1 有效 / 2 已使用 / 3 已过期 / 4 转赠中。
  Future<ApiResponse<CouponGroupListResult>> getCouponGroupList({required CouponGroupStatus status}) async {
    return _apiClient.post<CouponGroupListResult>(
      '/api/promotion/getcoupongrouplist',
      data: <String, dynamic>{'status': status.apiValue, 'groupid': 0, 'receivecrmcoupon': false, 'receivewelfare': false},
      fromJson: (dynamic json) => CouponGroupListResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取用户待解锁红包列表。
  ///
  /// 接口：POST /api/promotion/getcashcouponlist
  /// 请求体：{status, pageindex, pagesize}
  /// 状态：1 有效 / 2 已使用 / 3 已过期。
  Future<ApiResponse<CashCouponListResult>> getCashCouponList({required CashCouponStatus status, required int pageIndex, required int pageSize}) async {
    return _apiClient.post<CashCouponListResult>(
      '/api/promotion/getcashcouponlist',
      data: <String, dynamic>{'status': status.apiValue, 'pageindex': pageIndex, 'pagesize': pageSize},
      fromJson: (dynamic json) => CashCouponListResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取用户待解锁红包详情。
  ///
  /// 接口：POST /api/promotion/getcashcoupondetail
  /// 请求体：{couponsn}
  Future<ApiResponse<CashCouponDetailResult>> getCashCouponDetail({required String couponSn}) async {
    return _apiClient.post<CashCouponDetailResult>(
      '/api/promotion/getcashcoupondetail',
      data: <String, dynamic>{'couponsn': couponSn},
      fromJson: (dynamic json) => CashCouponDetailResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取可用福利列表。
  ///
  /// 接口：POST /api/promotion/availablewelfarelist
  /// 请求体：{cardonly}
  Future<ApiResponse<AvailableWelfareListResult>> getAvailableWelfareList({required bool cardOnly}) async {
    return _apiClient.post<AvailableWelfareListResult>(
      '/api/promotion/availablewelfarelist',
      data: <String, dynamic>{'cardonly': cardOnly},
      fromJson: (dynamic json) => AvailableWelfareListResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 发起会员待解锁红包分享；会员权益来源分享必须传入 userserviceid。
  ///
  /// 接口：POST /api/promotion/cashcoupons/begincashcouponshare
  /// 请求体：{userserviceid, cashcouponconfigid}
  Future<ApiResponse<BeginCashCouponShareResult>> beginCashCouponShare({required int userServiceId, required int cashCouponConfigId}) async {
    return _apiClient.post<BeginCashCouponShareResult>(
      '/api/promotion/cashcoupons/begincashcouponshare',
      data: <String, dynamic>{'userserviceid': userServiceId, 'cashcouponconfigid': cashCouponConfigId},
      fromJson: (dynamic json) => BeginCashCouponShareResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 通过分享编号预览或领取待解锁红包。
  ///
  /// 接口：POST /api/promotion/cashcoupons/recvcashcouponfromshare
  /// 请求体：{dorecv, sharecode}；false 仅查询，true 实际领取。
  Future<ApiResponse<ReceiveCashCouponFromShareResult>> receiveCashCouponFromShare({required String shareCode, required bool doReceive}) async {
    return _apiClient.post<ReceiveCashCouponFromShareResult>(
      '/api/promotion/cashcoupons/recvcashcouponfromshare',
      data: <String, dynamic>{'dorecv': doReceive, 'sharecode': shareCode},
      fromJson: (dynamic json) => ReceiveCashCouponFromShareResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取服务券列表。
  ///
  /// 接口：POST /api/promotion/getservicecouponlist
  /// 请求体：{status, selfsetonly}
  /// 状态：0 未使用 / 1 已失效 / 2 转赠中。
  Future<ApiResponse<ServiceCouponListResult>> getServiceCouponList({required ServiceCouponStatus status, bool selfSetOnly = false}) async {
    return _apiClient.post<ServiceCouponListResult>(
      '/api/promotion/getservicecouponlist',
      data: <String, dynamic>{'status': status.apiValue, 'selfsetonly': selfSetOnly},
      fromJson: (dynamic json) => ServiceCouponListResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 刷新服务券兑换信息。
  ///
  /// 接口：POST /api/promotion/v2/refreshservicecouponinfov2
  /// 请求体：{userid: null, coupontypeid, count, perfercouponsn}
  Future<ApiResponse<ServiceCouponInfoResult>> refreshServiceCouponInfoV2({required int couponTypeId, required int count, String? preferCouponSn}) async {
    return _apiClient.post<ServiceCouponInfoResult>(
      '/api/promotion/v2/refreshservicecouponinfov2',
      data: <String, dynamic>{'userid': null, 'coupontypeid': couponTypeId, 'count': count, 'perfercouponsn': preferCouponSn},
      fromJson: (dynamic json) => ServiceCouponInfoResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 转赠服务券。
  ///
  /// 接口：POST /api/promotion/giveservicecoupon
  /// 请求体：{serviceconponid, count}（字段名按接口文档保留）。
  /// 响应：{sharegroup, datatag}，sharegroup 用于生成领取分享链接。
  Future<ApiResponse<GiveServiceCouponResult>> giveServiceCoupon({required int serviceCouponId, required int count}) async {
    return _apiClient.post<GiveServiceCouponResult>(
      '/api/promotion/giveservicecoupon',
      data: <String, dynamic>{'serviceconponid': serviceCouponId, 'count': count},
      fromJson: (dynamic json) => GiveServiceCouponResult.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  /// 取消转赠服务券。
  ///
  /// 接口：POST /api/promotion/giveservicecouponreovoke
  /// 请求体：{serviceconponid, sharegroup}
  /// `serviceconponid` 为文档保留字段名；取消转赠以列表返回的 `sharegroup` 定位转赠记录。
  Future<ApiResponse<void>> revokeServiceCoupon({required int serviceCouponId, required String shareGroup}) async {
    return _apiClient.post<void>(
      '/api/promotion/giveservicecouponreovoke',
      data: <String, dynamic>{'serviceconponid': serviceCouponId, 'sharegroup': shareGroup},
    );
  }

  /// 领取好友转赠的服务券。
  ///
  /// 接口：POST /api/promotion/receiveservicecoupon
  /// 请求体：{sharegroupid, serviceconponid, dry}
  /// - sharegroupid：转赠接口返回的分享批次 id。
  /// - serviceconponid：服务券 id；传了 sharegroupid 时后端可忽略。
  /// - dry：true 只校验不实际领取，false 执行领取。
  Future<ApiResponse<void>> receiveServiceCoupon({required String shareGroupId, int serviceCouponId = 0}) async {
    return _apiClient.post<void>(
      '/api/promotion/receiveservicecoupon',
      data: <String, dynamic>{'sharegroupid': shareGroupId, 'serviceconponid': serviceCouponId, 'dry': false},
    );
  }
}

/// MemberRemoteDataSource Provider
final memberRemoteDataSourceProvider = Provider<MemberRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return MemberRemoteDataSource(apiClient);
});

class _AreaInfo {
  final int districtId;

  const _AreaInfo({required this.districtId});

  factory _AreaInfo.fromJson(Map<String, dynamic> json) {
    final value = json['districtid'];
    final districtId = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    return _AreaInfo(districtId: districtId);
  }
}
