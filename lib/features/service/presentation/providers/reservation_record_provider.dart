import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_remote_datasource.dart';
import '../../domain/models/reservation_record_item.dart';

/// 预约/报名记录列表 Provider（family，按 reservationlisttype 加载）
///
/// [reservationlisttype] 取值：
///   0 = 全部
///   1 = 已预约（默认）
///   2 = 已完成
///
/// autoDispose：页面销毁时自动释放。
final myReservationListProvider =
    FutureProvider.family.autoDispose<List<ReservationRecordItem>, int>((ref, listType) async {
  final dataSource = ref.read(serviceRemoteDataSourceProvider);
  final response = await dataSource.getMyReservationList(reservationListType: listType);
  return response.requireData;
});
