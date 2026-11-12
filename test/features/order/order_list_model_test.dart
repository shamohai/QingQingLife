import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/core/network/api_response.dart';
import 'package:qingqinglife/features/order/data/models/order_list_response.dart';
import 'package:qingqinglife/features/order/domain/entities/order_list_order.dart';
import 'package:qingqinglife/features/order/presentation/widgets/order_card.dart';

Map<String, dynamic> _response({List<int> ids = const [], int total = 0}) => {
  'result': 0,
  'descr': null,
  'datatag': null,
  'totalcount': total,
  'orderlist': ids.map((id) => {'orderid': id, 'ordercode': '000$id', 'orderstate': 110, 'ordertype': 8}).toList(),
};

void main() {
  test('amounts use decimal yuan conversion and missing values stay missing', () {
    expect(yuanToCents('19.99'), 1999);
    expect(yuanToCents(0.29), 29);
    expect(yuanToCents('0.005'), 1);
    expect(yuanToCents(0), 0);
    expect(yuanToCents(null), isNull);
    expect(yuanToCents('invalid'), isNull);
    final order = OrderListOrderModel.fromJson({}).toDomain();
    expect(order.typeCode, isNull);
    expect(order.stateCode, isNull);
    expect(order.amountCents, isNull);
    expect(order.consumedPoints, isNull);
    expect(order.createdAt, isNull);
    expect(order.typeLabel, '未知订单类型');
  });

  test('all backend enum remarks and state codes are preserved', () {
    const labels = {
      0: '老酒订单',
      1: '定制酒订单',
      2: '积分订单',
      3: '礼品卡订单',
      4: '文创定制订单',
      5: '抽奖礼品订单',
      6: '封坛订单',
      7: '福禄积分订单',
      8: '热销产品订单',
      9: '服务券提货订单',
      20: '特供订单',
      21: '合作权益订单',
      22: '特殊纪念订单',
      23: '服务券购买订单',
      25: '百礼汇积分订单',
    };
    for (final entry in labels.entries) {
      expect(OrderListOrder(typeCode: entry.key).typeLabel, entry.value);
    }
    expect(BackendOrderState.values.map((state) => state.code), [0, 30, 50, 60, 90, 110, 130, 140, 160, 180, 200, 300]);
    final unknown = OrderListOrderModel.fromJson({'orderstate': 999, 'ordertype': 888}).toDomain();
    expect(unknown.stateCode, 999);
    expect(unknown.typeCode, 888);
    expect(unknown.typeLabel, contains('888'));
    expect(unknown.statusLabel, contains('999'));
  });

  test('flat response maps all products, independent amounts and exact action flags', () {
    final json = _response(ids: [1], total: 1);
    (json['orderlist'] as List)[0].addAll({
      'orderstatedesc': '待核销',
      'orderamount': '19.99',
      'payamount': '10.29',
      'creditamount': '123.5',
      'iscreditorder': false,
      'createtime': '2026-10-20 12:30:45',
      'cancle': true,
      'confirm': true,
      'payment': false,
      'payend': true,
      'evaluate': true,
      'aftersale': true,
      'cancelafter': true,
      'products': [
        {
          'pid': 10,
          'productname': '商品一',
          'showimg': 'one.png',
          'shopprice': '9.99',
          'payamountdescr': '¥9.99',
          'num': 2,
          'description': '规格说明',
          'parameter': [
            {'name': '度数', 'value': '52°   '},
            {'name': '香型', 'value': '清香型   '},
            {'name': '规格', 'value': '500ml*6'},
          ],
        },
        {'pid': 20, 'pname': '兼容名称', 'img': 'two.png', 'price': '0', 'num': 1, 'iscreditproduct': true, 'creditprice': 123},
      ],
    });
    final response = ApiResponse<OrderListResponse>.fromJson(json, (data) => OrderListResponse.fromJson(data as Map<String, dynamic>));
    final page = response.requireData.toDomain(page: 1, pageSize: 20);
    final order = page.orders.single;
    expect(order.amountCents, 1999);
    expect(order.paidAmountCents, 1029);
    expect(order.consumedPoints, '123.5');
    expect(order.isCreditOrder, isFalse);
    expect(order.statusLabel, '待核销');
    expect(order.products.map((product) => product.name), ['商品一', '兼容名称']);
    expect(order.products.first.priceCents, 999);
    expect(order.products.first.payAmountDescription, '¥9.99');
    expect(order.products.first.priceDescription, '规格说明');
    expect(order.products.first.parameters.map((parameter) => '${parameter.name}:${parameter.value}'), ['度数:52°', '香型:清香型', '规格:500ml*6']);
    expect(order.products.last.priceCents, 0);
    expect(order.products.last.creditPrice, '123');
    expect(order.actions, [
      OrderListAction.cancel,
      OrderListAction.afterSale,
      OrderListAction.cancelAfterSale,
      OrderListAction.payBalance,
      OrderListAction.confirm,
      OrderListAction.evaluate,
    ]);
    expect(page.hasMore, isFalse);
  });

  test('credit order uses creditamount for total and creditprice for products', () {
    final json = _response(ids: [2], total: 1);
    (json['orderlist'] as List)[0].addAll({
      'iscreditorder': true,
      'creditamount': '1000',
      'orderamount': '0',
      'products': [
        {'productname': '积分商品', 'creditprice': '500', 'shopprice': '99.99', 'num': 2},
      ],
    });
    final response = ApiResponse<OrderListResponse>.fromJson(json, (data) => OrderListResponse.fromJson(data as Map<String, dynamic>));
    final order = response.requireData.toDomain(page: 1, pageSize: 20).orders.single;
    expect(order.isCreditOrder, isTrue);
    expect(order.consumedPoints, '1000');
    expect(order.products.single.creditPrice, '500');
    expect(order.products.single.priceCents, 9999);
  });

  test('empty page stops pagination and malformed response is not silently empty', () {
    expect(OrderListResponse.fromJson(_response(total: 99)).toDomain(page: 1, pageSize: 20).hasMore, isFalse);
    expect(() => OrderListResponse.fromJson({}), throwsFormatException);
  });

  for (final isCreditOrder in [true, false]) {
    testWidgets('prices are mutually exclusive when iscreditorder=$isCreditOrder', (tester) async {
      final order = OrderListOrderModel.fromJson({
        'iscreditorder': isCreditOrder,
        'creditamount': '1000',
        'orderamount': '100.00',
        'products': [
          {'productname': '测试商品', 'creditprice': '500', 'shopprice': '50.00', 'num': 2, 'iscreditproduct': !isCreditOrder},
        ],
      }).toDomain();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OrderCard(item: order)),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is RichText && widget.text.toPlainText() == '总计: 1000积分'),
        isCreditOrder ? findsOneWidget : findsNothing,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is RichText && widget.text.toPlainText() == '¥100.00'),
        isCreditOrder ? findsNothing : findsOneWidget,
      );
      expect(find.text('500积分'), isCreditOrder ? findsOneWidget : findsNothing);
      expect(find.text('¥50.00'), isCreditOrder ? findsNothing : findsOneWidget);
      expect(find.textContaining('消耗积分'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [320.0, 375.0, 440.0]) {
    testWidgets('multi product card keeps missing fields visible and buttons fit $width px', (tester) async {
      final status = switch (width) {
        320.0 => '待发货',
        375.0 => '已完成',
        _ => '退款完成',
      };
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: OrderCard(
                  item: OrderListOrder(
                    orderNo: '000000000000000000000001234567890',
                    typeCode: 23,
                    stateCode: 110,
                    stateDescription: status,
                    amountCents: 1999,
                    consumedPoints: '123.5',
                    isCreditOrder: false,
                    products: const [
                      OrderListProduct(name: '商品一', priceCents: 999, quantity: 2),
                      OrderListProduct(name: '商品二'),
                    ],
                    actions: OrderListAction.values,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final headerStatus = find.text(status).first;
      final header = find.ancestor(of: headerStatus, matching: find.byType(Row)).first;
      expect(tester.getRect(headerStatus).right, closeTo(tester.getRect(header).right, 0.1));
      expect(find.text('商品一'), findsOneWidget);
      expect(find.text('商品二'), findsOneWidget);
      expect(find.text('¥9.99'), findsOneWidget);
      expect(find.text('总计: '), findsOneWidget);
      expect(find.byWidgetPredicate((widget) => widget is RichText && widget.text.toPlainText() == '¥19.99'), findsOneWidget);
      expect(find.textContaining('消耗积分'), findsNothing);
      expect(find.text('下单时间: 暂无'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('立即付款'));
      await tester.pump();
      expect(find.text('立即付款接口暂未接入'), findsOneWidget);
    });
  }
}
