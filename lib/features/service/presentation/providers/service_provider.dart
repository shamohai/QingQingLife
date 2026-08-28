import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/service_item.dart';

final serviceDataProvider = Provider<List<ServiceItem>>((ref) {
  return ServiceItem.staticList;
});

class ServiceTabNotifier extends Notifier<String> {
  @override
  String build() => 'ongoing';

  void setTab(String tab) => state = tab;
}

final serviceTabProvider = NotifierProvider<ServiceTabNotifier, String>(
  () => ServiceTabNotifier(),
);
