import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_remote_datasource.dart';
import '../../domain/models/offline_activity_detail_model.dart';

/// 线下活动详情 Provider（family，按 activityId 加载）
///
/// 用于挚友报名会 / 活动报名 tab 的详情页。
/// autoDispose：页面销毁时自动释放。
final offlineActivityDetailProvider = FutureProvider.family.autoDispose<OfflineActivityDetail, String>((ref, activityId) async {
  final dataSource = ref.read(serviceRemoteDataSourceProvider);
  final response = await dataSource.getOfflineActivityDetail(activityId);
  return response.requireData;
});
