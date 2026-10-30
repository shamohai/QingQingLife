import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_remote_datasource.dart';
import '../../domain/models/reservation_service_detail_model.dart';

/// Reservation detail request scoped to the booking record detail page.
final reservationBookingRecordDetailProvider = FutureProvider.family.autoDispose<ReservationServiceDetail, int>((ref, serviceId) async {
  final dataSource = ref.read(serviceRemoteDataSourceProvider);
  final response = await dataSource.getReservationServiceDetail(serviceId);
  return response.requireData;
});
