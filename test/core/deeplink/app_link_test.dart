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

  group('AppLink.dispatchRedirect', () {
    test('resolves the dispatch entry to the target page', () {
      final location = AppLink.dispatchRedirect(Uri.parse('/link/dispatch?route=%2Fnotifications&messageid=42'));

      expect(location, '/notifications?messageid=42');
    });

    test('ignores paths that are not the dispatch entry', () {
      expect(AppLink.dispatchRedirect(Uri.parse('/notifications?tab=system')), isNull);
      expect(AppLink.dispatchRedirect(Uri.parse('/product/12')), isNull);
    });

    test('keeps the dispatch page when the link is invalid', () {
      expect(AppLink.dispatchRedirect(Uri.parse('/link/dispatch')), isNull);
      expect(AppLink.dispatchRedirect(Uri.parse('/link/dispatch?route=')), isNull);
      expect(AppLink.dispatchRedirect(Uri.parse('/link/dispatch?route=%2Funknown%2Fpage')), isNull);
    });

    test('refuses protected entry points and dead-end payment pages', () {
      expect(AppLink.dispatchRedirect(Uri.parse('/link/dispatch?route=%2Flogin')), isNull);
      expect(AppLink.dispatchRedirect(Uri.parse('/link/dispatch?route=%2Fpayment-result')), isNull);
    });

    test('does not redirect into the dispatch page itself', () {
      expect(AppLink.dispatchRedirect(Uri.parse('/link/dispatch?route=%2Flink%2Fdispatch')), isNull);
    });

    test('forwards extra query parameters to the target page', () {
      final location = AppLink.dispatchRedirect(Uri.parse('/link/dispatch?route=%2Fcoupons%2Fcash%2Freceive&sharecode=abc123'));

      expect(location, '/coupons/cash/receive?sharecode=abc123');
    });
  });
}
