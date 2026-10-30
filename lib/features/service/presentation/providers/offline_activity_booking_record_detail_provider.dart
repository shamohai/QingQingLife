import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_remote_datasource.dart';
import '../../domain/models/offline_activity_detail_model.dart';

/// Offline activity detail request scoped to the booking record detail page.
final offlineActivityBookingRecordDetailProvider = FutureProvider.family.autoDispose<OfflineActivityDetail, String>((ref, activityId) async {
  final dataSource = ref.read(serviceRemoteDataSourceProvider);
  final response = await dataSource.getOfflineActivityDetail(activityId);
  return response.requireData;
});
