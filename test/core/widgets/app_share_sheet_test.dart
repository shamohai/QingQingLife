import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/core/share/share_payload.dart';
import 'package:qingqinglife/core/share/share_provider.dart';
import 'package:qingqinglife/core/share/share_service.dart';
import 'package:qingqinglife/core/widgets/app_share_sheet.dart';

class _FakeShareService implements ShareService {
  SharePayload? payload;
  ShareChannel? channel;

  @override
  Future<ShareActionResult> share(SharePayload payload, ShareChannel channel) async {
    this.payload = payload;
    this.channel = channel;
    return const ShareActionResult(ShareActionStatus.success);
  }
}

void main() {
  testWidgets('shows system fallback without a URL and calls the share service', (tester) async {
    final service = _FakeShareService();
    const payload = SharePayload(title: '积分服务', description: '服务说明');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [shareServiceProvider.overrideWith((ref) => service)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => AppShareSheet.show(context: context, payload: payload),
                child: const Text('打开分享'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开分享'));
    await tester.pumpAndSettle();
    expect(find.text('更多'), findsOneWidget);
    expect(find.text('微信好友'), findsNothing);
    expect(find.text('朋友圈'), findsNothing);
    expect(find.text('复制链接'), findsNothing);

    await tester.tap(find.text('更多'));
    await tester.pumpAndSettle();
    expect(service.channel, ShareChannel.system);
    expect(service.payload, payload);
  });

  testWidgets('shows WeChat and copy actions only when a real web URL exists', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: _ShareSheetTestPage())));
    await tester.tap(find.text('打开分享'));
    await tester.pumpAndSettle();
    expect(find.text('微信好友'), findsOneWidget);
    expect(find.text('朋友圈'), findsOneWidget);
    expect(find.text('复制链接'), findsOneWidget);
    expect(find.text('更多'), findsOneWidget);
  });
}

class _ShareSheetTestPage extends StatelessWidget {
  const _ShareSheetTestPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        onPressed: () => AppShareSheet.show(
          context: context,
          payload: const SharePayload(title: '服务', url: 'https://example.com/service/1'),
        ),
        child: const Text('打开分享'),
      ),
    );
  }
}
