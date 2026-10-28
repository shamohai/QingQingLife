import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../../../core/presentation/paging/paging_list_view.dart';
import '../../data/datasources/service_remote_datasource.dart';
import '../../domain/models/offline_activity_record_item.dart';

/// 活动报名记录分页 Notifier
///
/// 调用 POST /api/promotion/app/activity/getmyofflineactivitylist
/// 支持 pageIndex / pageSize 分页加载。
class OfflineActivityRecordNotifier extends PagingNotifier<OfflineActivityRecordItem> {
  @override
  int get pageSize => 10;

  @override
  Future<PagingResult<OfflineActivityRecordItem>> fetchPage(int page, int pageSize) async {
    final dataSource = ref.read(serviceRemoteDataSourceProvider);
    final response = await dataSource.getMyOfflineActivityList(pageIndex: page, pageSize: pageSize);
    final items = response.requireData;
    return PagingResult(items: items, hasMore: items.length == pageSize, totalItems: items.length, totalPages: (items.length / pageSize).ceil());
  }
}

final myOfflineActivityRecordProvider = NotifierProvider.autoDispose<OfflineActivityRecordNotifier, PagingData<OfflineActivityRecordItem>>(
  OfflineActivityRecordNotifier.new,
);
