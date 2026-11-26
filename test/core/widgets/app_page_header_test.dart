import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/core/widgets/app_page_header.dart';

void main() {
  testWidgets('uses a consistent 44dp row and applies page-specific styling', (tester) async {
    var backPressed = false;
    const backgroundColor = Color(0xFF123456);
    const titleColor = Color(0xFFFFFFFF);
    const iconColor = Color(0xFFEEEEEE);
    const headerKey = Key('page_header');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPageHeader(
            key: headerKey,
            title: '个人信息',
            onBack: () => backPressed = true,
            backgroundColor: backgroundColor,
            titleStyle: const TextStyle(color: titleColor),
            iconColor: iconColor,
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(headerKey)).height, 44);
    final headerCenterY = tester.getTopLeft(find.byKey(headerKey)).dy + 22;
    expect(tester.getCenter(find.byIcon(Icons.arrow_back_ios_new)).dy, headerCenterY);
    expect(tester.getCenter(find.text('个人信息')).dy, headerCenterY);
    expect(tester.widget<Container>(find.descendant(of: find.byKey(headerKey), matching: find.byType(Container))).color, backgroundColor);
    expect(tester.widget<Text>(find.text('个人信息')).style?.color, titleColor);
    expect(tester.widget<Icon>(find.byIcon(Icons.arrow_back_ios_new)).color, iconColor);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    expect(backPressed, isTrue);
  });

  testWidgets('supports independent left, center, and right content', (tester) async {
    var rightActionPressed = false;
    const headerKey = Key('slot_header');
    const leftKey = Key('left_slot');
    const centerKey = Key('center_slot');
    const rightKey = Key('right_slot');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppPageHeader(
            key: headerKey,
            left: SizedBox(key: leftKey, width: 44, height: 44),
            center: SizedBox(key: centerKey, width: 100, height: 44),
            right: SizedBox(key: rightKey, width: 44, height: 44),
          ),
        ),
      ),
    );

    expect(find.byKey(leftKey), findsOneWidget);
    expect(find.byKey(centerKey), findsOneWidget);
    expect(find.byKey(rightKey), findsOneWidget);
    expect(tester.getTopLeft(find.byKey(leftKey)).dx, 0);
    expect(tester.getTopLeft(find.byKey(centerKey)).dx, 44);
    expect(tester.getTopLeft(find.byKey(rightKey)).dx, tester.getSize(find.byKey(headerKey)).width - 44);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPageHeader(
            left: const SizedBox(width: 44, height: 44),
            title: '通知列表',
            right: IconButton(key: rightKey, tooltip: '清理', onPressed: () => rightActionPressed = true, icon: const Icon(Icons.delete_outline)),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(rightKey));
    expect(rightActionPressed, isTrue);
  });

  testWidgets('fits the Scaffold app bar safe area', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    tester.view.padding = const FakeViewPadding(top: 24);
    tester.view.viewPadding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: AppPageHeader(title: '订单详情', onBack: _ignoreTap, height: kToolbarHeight, safeAreaTop: true),
          body: SizedBox.expand(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getCenter(find.text('订单详情')).dy, 24 + kToolbarHeight / 2);
  });
}

void _ignoreTap() {}
