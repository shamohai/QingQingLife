import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/features/points/mall/presentation/providers/butler_mini_program_provider.dart';
import 'package:qingqinglife/features/service/presentation/pages/service_customer_contact_page.dart';

const _fluwxChannel = MethodChannel('com.jarvanmo/fluwx');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses ordinary customer service data from the default response node', () {
    final info = ButlerMiniProgramInfo.fromJson({
      'info': {
        'default': {
          'wxcustomerserviceurl': 'https://work.weixin.qq.com/kfid/kfcustomer',
          'workwxcorpid': 'ww1234567890',
          'servicedescr': '工作时间 9:00-18:00',
          'fallbacktel': '400-800-8888',
        },
      },
    });

    expect(info.defaultConfig?.wxcustomerserviceurl, 'https://work.weixin.qq.com/kfid/kfcustomer');
    expect(info.defaultConfig?.workwxcorpid, 'ww1234567890');
    expect(info.defaultConfig?.fallbacktel, '400-800-8888');
  });

  testWidgets('opens WeChat customer service with API-provided corpId and URL', (tester) async {
    final openRequests = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_fluwxChannel, (call) async {
      switch (call.method) {
        case 'isWeChatInstalled':
          return true;
        case 'openWeChatCustomerServiceChat':
          openRequests.add(call);
          return true;
        default:
          throw MissingPluginException('Unexpected Fluwx call: ${call.method}');
      }
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_fluwxChannel, null));

    final info = ButlerMiniProgramInfo(
      defaultConfig: const ButlerDefaultInfo(
        wxcustomerserviceurl: 'https://work.weixin.qq.com/kfid/kfcustomer',
        workwxcorpid: 'ww1234567890',
        servicedescr: '工作时间 9:00-18:00',
        fallbacktel: '400-800-8888',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [butlerMiniProgramInfoProvider.overrideWith((ref) async => info)],
        child: const MaterialApp(home: ServiceCustomerContactPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('进入微信客服'), findsOneWidget);
    await tester.tap(find.text('进入微信客服'));
    await tester.pumpAndSettle();

    expect(openRequests, hasLength(1));
    expect(openRequests.single.arguments, {'corpId': 'ww1234567890', 'url': 'https://work.weixin.qq.com/kfid/kfcustomer'});
  });

  testWidgets('shows fallback guidance when WeChat denies customer service deeplink permission', (tester) async {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_fluwxChannel, (call) async {
      switch (call.method) {
        case 'isWeChatInstalled':
          return true;
        case 'openWeChatCustomerServiceChat':
          return true;
        default:
          throw MissingPluginException('Unexpected Fluwx call: ${call.method}');
      }
    });
    addTearDown(() => messenger.setMockMethodCallHandler(_fluwxChannel, null));

    final info = ButlerMiniProgramInfo(
      defaultConfig: const ButlerDefaultInfo(
        wxcustomerserviceurl: 'https://work.weixin.qq.com/kfid/kfcustomer',
        workwxcorpid: 'ww1234567890',
        fallbacktel: '400-800-8888',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [butlerMiniProgramInfoProvider.overrideWith((ref) async => info)],
        child: const MaterialApp(home: ServiceCustomerContactPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('进入微信客服'));
    await tester.pump();

    await messenger.handlePlatformMessage(
      _fluwxChannel.name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('onWXOpenCustomerServiceChatResponse', <String, dynamic>{'errCode': -1, 'errStr': 'deeplink customerservice no permission'}),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();

    expect(find.text('微信客服权限未开通，可拨打备用电话 400-800-8888'), findsOneWidget);
  });
}
