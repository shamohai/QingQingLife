import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_remote_datasource.dart';
import '../../domain/models/service_project_detail_model.dart';

/// 预约项目详情数据异步 Provider（family，按 projectId 加载）
///
/// autoDispose：页面销毁时自动释放。
///
/// 详情数据仅从 getreservationservicedetail 接口获取；
/// 接口失败或 projectId 非法时直接抛出错误，由页面 Error 状态承接，不再回退静态 mock。
final serviceProjectDetailProvider = FutureProvider.family.autoDispose<ServiceProjectDetail, String>((ref, projectId) async {
  final serviceId = int.tryParse(projectId);
  if (serviceId == null || serviceId <= 0) {
    throw ArgumentError.value(projectId, 'projectId', '预约项目 ID 无效');
  }
  final dataSource = ref.read(serviceRemoteDataSourceProvider);
  final response = await dataSource.getReservationServiceDetail(serviceId);
  final detail = response.requireData;

  return ServiceProjectDetail(
    id: detail.serviceId.toString(),
    title: detail.serviceName,
    heroAsset: detail.headImgUrl,
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
});
