import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/service_card_data.dart';
import '../../domain/models/service_record_item.dart';
import '../../data/datasources/service_remote_datasource.dart';
import '../../domain/models/share_cart_template_model.dart';
import '../../domain/models/reservation_service_item.dart';
import '../../domain/models/offline_activity_item.dart';

/// 按当前选中 Tab 过滤的服务列表卡片数据 Provider（静态 mock，待正式 API 对接后替换）
final serviceCardDataProvider = Provider<List<ServiceCardData>>((ref) {
  final tabKey = ref.watch(selectedTabProvider);
  return ServiceCardData.staticListByTab[tabKey] ?? const [];
});

/// 服务预约/报名记录数据 Provider
final serviceRecordDataProvider = Provider<List<ServiceRecordItem>>((ref) {
  return ServiceRecordItem.staticList;
});

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
