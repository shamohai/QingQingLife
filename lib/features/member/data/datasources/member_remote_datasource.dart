import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../models/member_authority_model.dart';

/// 会员数据源（对接真实 API）
/// 
/// 所有接口均通过 [ApiClient] 发起，加密/签名由拦截器自动处理。
class MemberRemoteDataSource {
  final ApiClient _apiClient;

  MemberRemoteDataSource(this._apiClient);

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
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/sys/v2/getmemberauthority',
      data: {'level': level},
    );
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
