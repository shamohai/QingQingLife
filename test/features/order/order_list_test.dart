import 'dart:async';

import 'package:dio/dio.dart' show Options;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/core/network/api_client.dart';
import 'package:qingqinglife/core/network/api_response.dart';
import 'package:qingqinglife/core/network/providers.dart';
import 'package:qingqinglife/features/order/data/datasources/order_datasource.dart';
import 'package:qingqinglife/features/order/presentation/pages/all_orders_page.dart';
import 'package:qingqinglife/features/order/presentation/providers/all_orders_provider.dart';

class _ApiClient extends Fake implements ApiClient {
  final requests = <Map<String, dynamic>>[];
  Future<Map<String, dynamic>> Function(Map<String, dynamic>) respond;

  _ApiClient(this.respond);

  @override
  Future<ApiResponse<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, T Function(dynamic)? fromJson, Options? options}) async {
    expect(path, '/api/order/getorderlist');
    final body = Map<String, dynamic>.from(data as Map);
    requests.add(body);
    return ApiResponse<T>.fromJson(await respond(body), fromJson);
  }
}

Map<String, dynamic> _response({List<int> ids = const [], int total = 0}) => {
  'result': 0,
  'descr': null,
  'datatag': null,
  'totalcount': total,
  'orderlist': ids.map((id) => {'orderid': id, 'ordercode': '000$id', 'orderstate': 110, 'ordertype': 8}).toList(),
};

ProviderContainer _container(_ApiClient client) {
  final container = ProviderContainer(overrides: [apiClientProvider.overrideWithValue(client)]);
  container.listen(allOrdersProvider, (_, _) {});
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('search uses exactly one field, preserves leading zeroes, and clears both', () async {
    final client = _ApiClient((_) async => _response());
    final dataSource = OrderDataSource(apiClient: client);
    for (final keyword in [' 001234 ', '青稞酒', '123abc', '12 34', '１２３', '   ']) {
      await dataSource.getOrderList(page: 1, pageSize: 20, orderState: 0, keyword: keyword);
    }
    expect(client.requests[0], {'orderstate': 0, 'ordercode': '001234', 'productname': null, 'pageindex': 1, 'pagesize': 20});
    for (var index = 1; index <= 4; index++) {
      expect(client.requests[index]['ordercode'], isNull);
      expect(client.requests[index]['productname'], ['青稞酒', '123abc', '12 34', '１２３'][index - 1]);
    }
    expect(client.requests.last['ordercode'], isNull);
    expect(client.requests.last['productname'], isNull);
  });

  test('pagination, duplicate suppression, refresh and search/tab resets', () async {
    final client = _ApiClient((body) async => body['pageindex'] == 1 ? _response(ids: [1], total: 21) : _response(ids: [1, 2], total: 21));
    final container = _container(client);
    final notifier = container.read(allOrdersProvider.notifier);
    await notifier.initialize();
    expect(container.read(allOrdersProvider).hasMore, isTrue);
    await notifier.loadMore();
    expect(container.read(allOrdersProvider).orders.map((order) => order.id), ['1', '2']);
    expect(container.read(allOrdersProvider).hasMore, isFalse);
    await notifier.loadMore();
    expect(client.requests.length, 2);
    await notifier.search('酒');
    expect(client.requests.last['pageindex'], 1);
    await notifier.selectTab(5);
    expect(client.requests.last['orderstate'], 160);
    expect(client.requests.last['productname'], '酒');
    await notifier.loadOrders();
    expect(client.requests.last['pageindex'], 1);
  });

  test('older responses cannot overwrite a newer search or tab', () async {
    final pending = <Completer<Map<String, dynamic>>>[];
    final client = _ApiClient((_) {
      final completer = Completer<Map<String, dynamic>>();
      pending.add(completer);
      return completer.future;
    });
    final container = _container(client);
    final notifier = container.read(allOrdersProvider.notifier);
    final initial = notifier.initialize();
    final search = notifier.search('商品');
    final tab = notifier.selectTab(3);
    pending[2].complete(_response(ids: [3], total: 1));
    await tab;
    pending[0].complete(_response(ids: [1], total: 1));
    pending[1].complete({'result': 1, 'descr': '旧请求失败'});
    await Future.wait([initial, search]);
    expect(container.read(allOrdersProvider).orders.single.id, '3');
    expect(container.read(allOrdersProvider).activeTabIndex, 3);
  });

  test('load more errors keep rows, set error state, and reset loading', () async {
    final pending = Completer<Map<String, dynamic>>();
    final client = _ApiClient((body) => body['pageindex'] == 1 ? Future.value(_response(ids: [1], total: 21)) : pending.future);
    final container = _container(client);
    final notifier = container.read(allOrdersProvider.notifier);
    await notifier.initialize();
    final first = notifier.loadMore();
    await notifier.loadMore();
    expect(client.requests.length, 2);
    pending.complete({'result': 1, 'descr': '请稍后重试'});
    await first;
    final state = container.read(allOrdersProvider);
    expect(state.error, isNotNull);
    expect(state.orders.single.id, '1');
    expect(state.page, 1);
    expect(state.isLoadingMore, isFalse);
    expect(state.hasMore, isTrue);
    client.respond = (_) async => _response(ids: [2], total: 21);
    await notifier.loadMore();
    expect(client.requests.last['pageindex'], 2);
    expect(container.read(allOrdersProvider).orders.map((order) => order.id), ['1', '2']);
  });

  for (final width in [320.0, 375.0, 440.0]) {
    testWidgets('order list fits $width px and empty results do not trigger reload loops', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final client = _ApiClient((_) async => _response());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(client)],
          child: const MaterialApp(home: AllOrdersPage(initialStatus: 'shipped')),
        ),
      );
      await tester.pumpAndSettle();
      expect(client.requests.single['orderstate'], 110);
      expect(find.text('暂无订单'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(client.requests.length, 1);
      await tester.enterText(find.byType(TextField), '000123');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(client.requests.last['ordercode'], '000123');
      await tester.tap(find.byTooltip('清空搜索'));
      await tester.pumpAndSettle();
      expect(client.requests.last['ordercode'], isNull);
      expect(client.requests.last['productname'], isNull);
      expect(tester.takeException(), isNull);
    });
  }

  test('initial failure sets error state, clears loading, and explicit retry reloads', () async {
    final client = _ApiClient((_) async => {'result': 1, 'descr': '订单获取失败'});
    final container = _container(client);
    final notifier = container.read(allOrdersProvider.notifier);
    await notifier.initialize();
    expect(client.requests.length, 1);
    final failed = container.read(allOrdersProvider);
    expect(failed.error, isNotNull);
    expect(failed.isLoading, isFalse);
    expect(failed.orders, isEmpty);
    client.respond = (_) async => _response();
    await notifier.loadOrders();
    expect(client.requests.length, 2);
    expect(container.read(allOrdersProvider).isLoading, isFalse);
  });
}
