import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_remote_datasource.dart';
import '../../../../core/network/exceptions/exceptions.dart';

/// 线下活动报名提交（挚友会 / 活动报名共用）
///
/// 返回 void，成功时不抛异常；失败时抛 ApiException，调用方捕获处理。
final signupOfflineActivityProvider = FutureProvider.family.autoDispose<void, Map<String, dynamic>>((ref, params) async {
  final dataSource = ref.read(serviceRemoteDataSourceProvider);
  final response = await dataSource.signupOfflineActivity(
    activityId: params['activityid'] as String,
    username: params['username'] as String,
    phone: params['phone'] as String,
    idNo: params['idno'] as String? ?? '',
    remark: params['remark'] as String? ?? '',
    signupUserCount: params['signupusercount'] as int? ?? 1,
  );
  // 仅校验 success，不要求 data（报名接口成功时可能无数据载荷）
  if (!response.success) throw ApiException(code: response.code, message: response.message);
});
