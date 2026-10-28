import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/exceptions.dart';
import '../../data/datasources/service_remote_datasource.dart';
import '../../domain/models/service_project_detail_model.dart';

/// 预约项目详情数据异步 Provider（family，按 projectId 加载）
///
/// autoDispose：页面销毁时自动释放。
///
/// 详情数据从 getreservationservicedetail 接口获取；
/// 当 projectId 为 mock 活动/挚友 ID 时，保留原有静态 mock 数据。
final serviceProjectDetailProvider =
    FutureProvider.family.autoDispose<ServiceProjectDetail, String>((ref, projectId) async {
  final serviceId = int.tryParse(projectId);
  if (serviceId == null || serviceId <= 0) {
    return ServiceProjectDetail.mock(projectId);
  }
  try {
    final dataSource = ref.read(serviceRemoteDataSourceProvider);
    final response = await dataSource.getReservationServiceDetail(serviceId);
    final detail = response.requireData;

    final heroFallback = ServiceProjectDetail.mock(projectId).heroAsset;
    return ServiceProjectDetail(
      id: detail.serviceId.toString(),
      title: detail.serviceName,
      heroAsset: detail.headImgUrl.isNotEmpty ? detail.headImgUrl : heroFallback,
      description: detail.descriptionHtml,
      onBook: () {},
      type: ServiceProjectDetailType.appointment,
      activityTime: null,
      registrationTime: null,
      activityAddress: null,
      limitCount: detail.maxReservationCount > 0 ? detail.maxReservationCount : null,
      detailImageAsset: null,
      subtitle: detail.subtitle,
      reservationRemark: detail.reservationRemark,
    );
  } on ApiException {
    // 非真实 serviceId（mock 数据）时接口可能 404，回退静态 mock
    return ServiceProjectDetail.mock(projectId);
  }
});
