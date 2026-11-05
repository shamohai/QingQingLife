import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/app/router/route_names.dart';
import 'package:qingqinglife/core/deeplink/app_link.dart';

void main() {
  group('AppLink dispatch locations', () {
    test('builds new links with the dispatch entry and preserves target parameters', () {
      final location = AppLink.buildDispatchLocation(route: RouteNames.notifications, parameters: const {'messageid': '42'});
      final uri = Uri.parse(location);

      expect(uri.path, RouteNames.appLinkDispatch);
      expect(uri.queryParameters['route'], RouteNames.notifications);
      expect(uri.queryParameters['messageid'], '42');
    });

    test('resolves target route and forwards dispatch parameters', () {
      final target = AppLink.resolveDispatchTarget(const {'route': '/notifications?tab=system', 'messageid': '42'});

      expect(target, '/notifications?tab=system&messageid=42');
    });

    test('prevents dispatch recursion', () {
      expect(() => AppLink.buildDispatchLocation(route: RouteNames.appLinkDispatch), throwsArgumentError);
      expect(AppLink.resolveDispatchTarget({'route': RouteNames.appLinkDispatch}), isNull);
    });

    test('accepts dispatch links from external app links', () {
      final location = AppLink.toAppLocation(Uri.parse('qingqinglife:///link/dispatch?route=%2Fnotifications'));

      expect(location, '/link/dispatch?route=%2Fnotifications');
    });
  });
}
