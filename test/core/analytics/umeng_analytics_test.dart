import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:qingqinglife/core/analytics/umeng_analytics.dart';
import 'package:qingqinglife/core/storage/privacy_consent_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tracks GoRouter pages manually after privacy consent', () async {
    final calls = <MethodCall>[];
    const channel = MethodChannel('umeng_common_sdk');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    });

    final analytics = UmengAnalytics(consentStorage: _MemoryPrivacyConsentStorage());
    await analytics.onPrivacyAccepted();
    analytics.trackPage(pageName: '/home', pageKey: '/home');
    analytics.trackPage(pageName: '/home', pageKey: '/home');
    analytics.trackPage(pageName: '/orders/:id', pageKey: 'push-1');
    analytics.onAppLifecycleChanged(AppLifecycleState.paused);
    analytics.onAppLifecycleChanged(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);

    expect(calls.map((call) => call.method), [
      'initCommon',
      'setPageCollectionModeManual',
      'onPageStart',
      'onPageEnd',
      'onPageStart',
      'onPageEnd',
      'onPageStart',
    ]);
    expect(calls.where((call) => call.method == 'onPageStart').map((call) => call.arguments), [
      ['/home'],
      ['/orders/:id'],
      ['/orders/:id'],
    ]);
  });
}

class _MemoryPrivacyConsentStorage extends PrivacyConsentStorage {
  @override
  Future<void> setAccepted(bool accepted) async {}
}
