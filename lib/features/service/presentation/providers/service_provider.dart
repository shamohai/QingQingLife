import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_remote_datasource.dart';
import '../../domain/models/share_cart_template_model.dart';
import '../../domain/models/reservation_service_item.dart';
import '../../domain/models/offline_activity_item.dart';

/// 购酒享服务模板列表 Provider（加载真实 API 数据，保持缓存避免 Tab 切换重复请求）
final shareCartTemplateProvider = AsyncNotifierProvider<ShareCartTemplateNotifier, List<ShareCartTemplate>>(
  () => ShareCartTemplateNotifier(),
  name: 'shareCartTemplateProvider',
);

class ShareCartTemplateNotifier extends AsyncNotifier<List<ShareCartTemplate>> {
  @override
  Future<List<ShareCartTemplate>> build() async {
    ref.keepAlive();
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

/// 服务预约列表 Provider（加载真实 API 数据，保持缓存避免 Tab 切换重复请求）
final reservationServiceListProvider = AsyncNotifierProvider<ReservationServiceListNotifier, List<ReservationServiceItem>>(
  () => ReservationServiceListNotifier(),
  name: 'reservationServiceListProvider',
);

class ReservationServiceListNotifier extends AsyncNotifier<List<ReservationServiceItem>> {
  @override
  Future<List<ReservationServiceItem>> build() async {
    ref.keepAlive();
    final dataSource = ref.read(serviceRemoteDataSourceProvider);
    final response = await dataSource.getReservationServiceList();
    return response.requireData;
  }
}

/// 挚友报名会列表 Provider（typdsfriends=true，保持缓存避免 Tab 切换重复请求）
final zhiyouhuiActivityListProvider = AsyncNotifierProvider<ZhiyouhuiActivityListNotifier, List<OfflineActivityItem>>(
  () => ZhiyouhuiActivityListNotifier(),
  name: 'zhiyouhuiActivityListProvider',
);

class ZhiyouhuiActivityListNotifier extends AsyncNotifier<List<OfflineActivityItem>> {
  @override
  Future<List<OfflineActivityItem>> build() async {
    ref.keepAlive();
    final dataSource = ref.read(serviceRemoteDataSourceProvider);
    final response = await dataSource.getOfflineActivityList(typdsfriends: true);
    return response.requireData;
  }
}

/// 活动报名列表 Provider（typdsfriends=false，保持缓存避免 Tab 切换重复请求）
final offlineActivityListProvider = AsyncNotifierProvider<OfflineActivityListNotifier, List<OfflineActivityItem>>(
  () => OfflineActivityListNotifier(),
  name: 'offlineActivityListProvider',
);

class OfflineActivityListNotifier extends AsyncNotifier<List<OfflineActivityItem>> {
  @override
  Future<List<OfflineActivityItem>> build() async {
    ref.keepAlive();
    final dataSource = ref.read(serviceRemoteDataSourceProvider);
    final response = await dataSource.getOfflineActivityList(typdsfriends: false);
    return response.requireData;
  }
}
