import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_remote_datasource.dart';
import '../../domain/models/reservation_service_detail_model.dart';

/// 预约服务详情数据异步 Provider（family，按 serviceId 加载）
///
/// 直接返回 [ReservationServiceDetail] 模型，不转换为统一的 ServiceProjectDetail。
/// 用于服务中心 - 服务预约 tab 的详情页。
final reservationServiceDetailProvider = FutureProvider.family.autoDispose<ReservationServiceDetail, int>((ref, serviceId) async {
  final dataSource = ref.read(serviceRemoteDataSourceProvider);
  final response = await dataSource.getReservationServiceDetail(serviceId);
  return response.requireData;
});

/// 独立于预约详情页缓存的预约记录详情请求。
final reservationBookingRecordDetailProvider = FutureProvider.family.autoDispose<ReservationServiceDetail, int>((ref, serviceId) async {
  final dataSource = ref.read(serviceRemoteDataSourceProvider);
  final response = await dataSource.getReservationServiceDetail(serviceId);
  return response.requireData;
});
