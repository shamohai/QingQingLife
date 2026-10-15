import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
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
}

/// MemberRemoteDataSource Provider
final memberRemoteDataSourceProvider = Provider<MemberRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return MemberRemoteDataSource(apiClient);
});
