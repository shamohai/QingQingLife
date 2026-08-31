import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/service_tier.dart';

class ActiveCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'wine';

  void setActive(String categoryId) => state = categoryId;
}

final activeCategoryProvider =
    NotifierProvider<ActiveCategoryNotifier, String>(
  () => ActiveCategoryNotifier(),
);

final serviceCategoriesProvider = Provider<List<ServiceCategory>>((ref) {
  return ServiceCategory.mockData;
});

/// 当前激活分类的商品/服务列表数据
final shopListDataProvider = Provider((ref) {
  final activeId = ref.watch(activeCategoryProvider);
  final cat = ServiceCategory.mockData.firstWhere(
    (c) => c.id == activeId,
    orElse: () => ServiceCategory.mockData.first,
  );
  return cat;
});

