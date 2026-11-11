import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_remote_datasource.dart';
import '../../domain/models/share_cart_template_model.dart';
import '../../domain/models/reservation_service_item.dart';
import '../../domain/models/offline_activity_item.dart';

/// 购酒享服务模板列表 Provider（加载真实 API 数据）
///
/// [ServiceRemoteDataSource]（需注入 apiClientProvider）。
final shareCartTemplateProvider = AsyncNotifierProvider<ShareCartTemplateNotifier, List<ShareCartTemplate>>(() => ShareCartTemplateNotifier());

class ShareCartTemplateNotifier extends AsyncNotifier<List<ShareCartTemplate>> {
  @override
  Future<List<ShareCartTemplate>> build() async {
    final dataSource = ref.read(serviceRemoteDataSourceProvider);
    final response = await dataSource.getShareCartTemplateList();
    return response.requireData;
  }
}

/// 当前选中的服务分类 Tab Provider
///
/// 一期无后端分页，所有分类数据相同；后续接入 API 后可按此 key 过滤。
final selectedTabProvider = NotifierProvider<ServiceTabNotifier, String>(() => ServiceTabNotifier());

class ServiceTabNotifier extends Notifier<String> {
  @override
  String build() => 'fuwu';

  void update(String tab) => state = tab;
}

/// 服务预约列表 Provider（加载真实 API 数据）
final reservationServiceListProvider = FutureProvider<List<ReservationServiceItem>>((ref) async {
  final dataSource = ref.read(serviceRemoteDataSourceProvider);
  final response = await dataSource.getReservationServiceList();
  return response.requireData;
});

/// 挚友报名会列表 Provider（typdsfriends=true）
final zhiyouhuiActivityListProvider = FutureProvider<List<OfflineActivityItem>>((ref) async {
  final dataSource = ref.read(serviceRemoteDataSourceProvider);
  final response = await dataSource.getOfflineActivityList(typdsfriends: true);
  return response.requireData;
});

/// 活动报名列表 Provider（typdsfriends=false）
final huodongActivityListProvider = FutureProvider<List<OfflineActivityItem>>((ref) async {
  final dataSource = ref.read(serviceRemoteDataSourceProvider);
  final response = await dataSource.getOfflineActivityList(typdsfriends: false);
  return response.requireData;
});
