import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_remote_datasource.dart';

/// 线下活动报名提交（挚友会 / 活动报名共用）
///
/// 返回 void，成功时抛 ApiSuccess；失败时抛 ApiException，调用方捕获处理。
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
  // result=0 表示成功；ApiException 由 requireData 抛出
  response.requireData;
});
