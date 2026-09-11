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
