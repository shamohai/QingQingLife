import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/service_card_data.dart';
import '../../domain/models/service_record_item.dart';

/// 服务列表卡片数据 Provider（静态 mock 数据，待正式 API 对接后替换）
final serviceCardDataProvider = Provider<List<ServiceCardData>>((ref) {
  return ServiceCardData.staticList;
});

/// 服务预约/报名记录数据 Provider
final serviceRecordDataProvider = Provider<List<ServiceRecordItem>>((ref) {
  return ServiceRecordItem.staticList;
});

/// 当前选中的服务分类 Tab Provider
/// 一期无后端分页，所有分类数据相同；后续接入 API 后可按此 key 过滤。
final selectedTabProvider = NotifierProvider<ServiceTabNotifier, String>(() => ServiceTabNotifier());

class ServiceTabNotifier extends Notifier<String> {
  @override
  String build() => 'golf';

  void update(String tab) => state = tab;
}
