import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_remote_datasource.dart';
import '../../domain/models/reservation_record_item.dart';

/// 预约记录列表 Provider（listType=0 全部，保持缓存避免 Tab 切换重复请求）
final myReservationListProvider = AsyncNotifierProvider<MyReservationListNotifier, List<ReservationRecordItem>>(
  () => MyReservationListNotifier(),
  name: 'myReservationListProvider',
);

class MyReservationListNotifier extends AsyncNotifier<List<ReservationRecordItem>> {
  @override
  Future<List<ReservationRecordItem>> build() async {
    ref.keepAlive();
    final dataSource = ref.read(serviceRemoteDataSourceProvider);
    final response = await dataSource.getMyReservationList(reservationListType: 0);
    return response.requireData;
  }
}
