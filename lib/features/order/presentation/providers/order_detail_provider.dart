import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/order_type.dart';
import '../../domain/repositories/order_repository.dart';
import '../../../../core/network/api_response.dart';

/// 订单详情页 Mock 数据 Provider
/// 根据 id（1-10 或 detail_1 ~ detail_10）返回对应的订单详情，覆盖所有测试场景
final mockOrderDetailProvider = Provider<ApiResponse<OrderDetail>>((ref) {
  return ApiResponse.success(getMockOrderDetail('1'));
});

/// 通用 Mock 数据映射
/// id: '1' ~ '10' 或 'detail_1' ~ 'detail_10' 对应 10 个测试用例
final mockOrderDetailByIdProvider = FutureProvider.family<ApiResponse<OrderDetail>, String>((ref, id) async {
  return ApiResponse.success(getMockOrderDetail(id));
});

OrderDetail getMockOrderDetail(String id) {
  final base = DateTime(2026, 10, 10, 12, 12, 11);

  // ID 归一化处理（例如 'detail_1' -> '1'）
  String cleanId = id;
  if (cleanId.startsWith('detail_')) {
    cleanId = cleanId.substring('detail_'.length);
  }

  // 通用商品（白酒）
  final commonItem = OrderItem(
    id: 'oi_1',
    productId: '1',
    skuId: 'sku_1',
    productName: '天佑德电商专供青稞酒特别版本...',
    skuName: '【规格一】天佑德电商专供青稞酒特别版本42度500ml',
    imageUrl: 'assets/images/product/product1.jpg',
    priceCents: 80000,
    quantity: 1,
    totalCents: 80000,
  );

  // 腾讯视频月卡商品
  final videoItem = OrderItem(
    id: 'oi_video',
    productId: 'video_1',
    skuId: 'sku_video',
    productName: '腾讯视频月卡',
    skuName: '腾讯视频月度会员卡',
    imageUrl: 'assets/images/product/product1.jpg',
    priceCents: 0,
    quantity: 1,
    totalCents: 0,
  );

  // 服务套餐商品
  final serviceItem = OrderItem(
    id: 'oi_service',
    productId: 'service_1',
    skuId: 'sku_service',
    productName: '接送机服务+美仑酒店一晚...',
    skuName: '【套餐服务一】接送机服务+美仑酒店一晚+青海湖沿线4人餐',
    imageUrl: 'assets/images/product/product1.jpg',
    priceCents: 80000,
    quantity: 1,
    totalCents: 80000,
  );

  final commonAddress = OrderAddress(
    id: 'addr_1',
    name: '吴彦祖',
    phone: '13098769987',
    province: '甘肃省',
    city: '兰州市',
    district: '七里河区',
    detail: '建兰路街道兰州中心办公楼801室',
    fullAddress: '甘肃省兰州市七里河区建兰路街道兰州中心办公楼801室',
  );

  switch (cleanId) {
    case '1':
    case 'svc_completed': // 1. 服务订单详情(交易完成)
      return OrderDetail(
        id: '1',
        orderNo: 'DDBH3456789',
        status: OrderStatus.completed,
        statusText: '交易完成',
        orderType: OrderType.service,
        items: [serviceItem],
        address: commonAddress,
        productTotalCents: 80000,
        shippingFeeCents: 0,
        discountCents: 0,
        pointsDeductedCents: 0,
        payAmountCents: 80000,
        createTime: base,
        receiveTime: base,
        timeline: [
          OrderTimeline(time: DateTime(2026, 10, 8, 10, 0), title: '下单', desc: '下单成功', status: OrderStatus.pendingPayment),
          OrderTimeline(time: DateTime(2026, 10, 8, 10, 5), title: '支付', desc: '已支付', status: OrderStatus.pendingPayment),
          OrderTimeline(time: DateTime(2026, 10, 9, 10, 0), title: '完成', desc: '已结算', status: OrderStatus.completed),
        ],
      );
    case '2':
    case 'pts_completed_coupon': // 2. 积分订单详情(交易完成 - 卡券)
      return OrderDetail(
        id: '2',
        orderNo: 'DDBH3456789',
        status: OrderStatus.completed,
        statusText: '交易完成',
        orderType: OrderType.points,
        pointsCost: 50,
        exchangeTime: base,
        items: [videoItem],
        address: commonAddress,
        productTotalCents: 0,
        shippingFeeCents: 0,
        discountCents: 0,
        pointsDeductedCents: 50,
        payAmountCents: 0,
        createTime: base,
        timeline: [
          OrderTimeline(time: DateTime(2026, 10, 8, 10, 0), title: '兑换', desc: '兑换成功', status: OrderStatus.completed),
          OrderTimeline(time: DateTime(2026, 10, 8, 10, 1), title: '充值', desc: '当前卡券已充值', status: OrderStatus.completed),
        ],
      );
    case '3':
    case 'pts_pending_shipment': // 3. 积分订单详情(待发货)
      return OrderDetail(
        id: '3',
        orderNo: 'DDBH3456789',
        status: OrderStatus.pendingShipment,
        statusText: '待发货',
        orderType: OrderType.points,
        pointsCost: 50,
        exchangeTime: base,
        items: [commonItem],
        address: commonAddress,
        productTotalCents: 0,
        shippingFeeCents: 0,
        discountCents: 0,
        pointsDeductedCents: 50,
        payAmountCents: 0,
        createTime: base,
        timeline: [
          OrderTimeline(time: DateTime(2026, 10, 8, 10, 0), title: '兑换', desc: '兑换成功', status: OrderStatus.pendingShipment),
          OrderTimeline(time: DateTime(2026, 10, 8, 10, 5), title: '发货', desc: '打包中', status: OrderStatus.pendingShipment),
        ],
      );
    case '4':
    case 'pts_virtual': // 4. 积分订单详情(虚拟商品)
      return OrderDetail(
        id: '4',
        orderNo: 'DDBH3456789',
        status: OrderStatus.completed,
        statusText: '交易完成',
        orderType: OrderType.points,
        pointsCost: 50,
        exchangeTime: base,
        items: [videoItem],
        address: commonAddress,
        productTotalCents: 0,
        shippingFeeCents: 0,
        discountCents: 0,
        pointsDeductedCents: 50,
        payAmountCents: 0,
        createTime: base,
        timeline: [
          OrderTimeline(time: DateTime(2026, 10, 8, 10, 0), title: '兑换', desc: '兑换成功', status: OrderStatus.completed),
        ],
      );
    case '5':
    case 'mall_completed': // 5. 商城订单详情(待评价)
      return OrderDetail(
        id: '5',
        orderNo: 'DDBH3456789',
        status: OrderStatus.completed,
        statusText: '待评价',
        orderType: OrderType.mall,
        items: [commonItem],
        address: commonAddress,
        productTotalCents: 80000,
        shippingFeeCents: 0,
        discountCents: 0,
        pointsDeductedCents: 0,
        payAmountCents: 80000,
        createTime: base,
        receiveTime: base.subtract(const Duration(days: 3)),
        timeline: [
          OrderTimeline(time: DateTime(2026, 10, 5, 10, 0), title: '下单', desc: '下单成功', status: OrderStatus.pendingPayment),
          OrderTimeline(time: DateTime(2026, 10, 5, 10, 5), title: '支付', desc: '已支付', status: OrderStatus.pendingPayment),
          OrderTimeline(time: DateTime(2026, 10, 6, 10, 0), title: '发货', desc: '已发货', status: OrderStatus.pendingShipment),
          OrderTimeline(time: DateTime(2026, 10, 8, 10, 0), title: '签收', desc: '已签收', status: OrderStatus.completed),
        ],
      );
    case '6':
    case 'mall_transaction_done': // 6. 商城订单详情(交易完成)
      return OrderDetail(
        id: '6',
        orderNo: 'DDBH3456789',
        status: OrderStatus.completed,
        statusText: '交易完成',
        orderType: OrderType.mall,
        items: [commonItem],
        address: commonAddress,
        productTotalCents: 80000,
        shippingFeeCents: 0,
        discountCents: 0,
        pointsDeductedCents: 0,
        payAmountCents: 80000,
        createTime: base,
        receiveTime: base.subtract(const Duration(days: 5)),
        timeline: [
          OrderTimeline(time: DateTime(2026, 10, 3, 10, 0), title: '下单', desc: '下单成功', status: OrderStatus.pendingPayment),
          OrderTimeline(time: DateTime(2026, 10, 3, 10, 5), title: '支付', desc: '已支付', status: OrderStatus.pendingPayment),
          OrderTimeline(time: DateTime(2026, 10, 4, 10, 0), title: '发货', desc: '已发货', status: OrderStatus.pendingShipment),
          OrderTimeline(time: DateTime(2026, 10, 6, 10, 0), title: '签收', desc: '已签收', status: OrderStatus.completed),
        ],
      );
    case '7':
    case 'mall_pending_review': // 7. 商城订单详情(待评价)
      return OrderDetail(
        id: '7',
        orderNo: 'DDBH3456789',
        status: OrderStatus.completed,
        statusText: '待评价',
        orderType: OrderType.mall,
        items: [commonItem],
        address: commonAddress,
        productTotalCents: 80000,
        shippingFeeCents: 0,
        discountCents: 0,
        pointsDeductedCents: 0,
        payAmountCents: 80000,
        createTime: base,
        receiveTime: base.subtract(const Duration(days: 1)),
        timeline: [
          OrderTimeline(time: DateTime(2026, 10, 8, 10, 0), title: '下单', desc: '下单成功', status: OrderStatus.pendingPayment),
          OrderTimeline(time: DateTime(2026, 10, 8, 10, 5), title: '支付', desc: '已支付', status: OrderStatus.pendingPayment),
          OrderTimeline(time: DateTime(2026, 10, 9, 10, 0), title: '发货', desc: '已发货', status: OrderStatus.pendingShipment),
          OrderTimeline(time: DateTime(2026, 10, 10, 10, 0), title: '签收', desc: '已签收', status: OrderStatus.completed),
        ],
      );
    case '8':
    case 'mall_shipped': // 8. 商城订单详情(待收货/待核销)
      return OrderDetail(
        id: '8',
        orderNo: 'DDBH3456789',
        status: OrderStatus.shipped,
        statusText: '待收货/待核销',
        orderType: OrderType.mall,
        pickupCode: '9-9-8788',
        items: [commonItem],
        address: commonAddress,
        productTotalCents: 80000,
        shippingFeeCents: 0,
        discountCents: 0,
        pointsDeductedCents: 0,
        payAmountCents: 80000,
        createTime: base,
        shipTime: base,
        timeline: [
          OrderTimeline(time: DateTime(2026, 10, 8, 10, 0), title: '下单', desc: '下单成功', status: OrderStatus.pendingPayment),
          OrderTimeline(time: DateTime(2026, 10, 8, 10, 5), title: '支付', desc: '已支付', status: OrderStatus.pendingPayment),
          OrderTimeline(time: DateTime(2026, 10, 9, 10, 0), title: '发货', desc: '已发货', status: OrderStatus.pendingShipment),
        ],
      );
    case '9':
    case 'mall_pending_shipment': // 9. 商城订单详情(待发货)
      return OrderDetail(
        id: '9',
        orderNo: 'DDBH3456789',
        status: OrderStatus.pendingShipment,
        statusText: '待发货',
        orderType: OrderType.mall,
        items: [commonItem],
        address: commonAddress,
        productTotalCents: 80000,
        shippingFeeCents: 0,
        discountCents: 0,
        pointsDeductedCents: 0,
        payAmountCents: 80000,
        createTime: base,
        payTime: base,
        timeline: [
          OrderTimeline(time: DateTime(2026, 10, 10, 12, 0), title: '下单', desc: '下单成功', status: OrderStatus.pendingPayment),
          OrderTimeline(time: DateTime(2026, 10, 10, 12, 5), title: '支付', desc: '已支付', status: OrderStatus.pendingPayment),
        ],
      );
    case '10':
    case 'mall_pending_payment': // 10. 商城订单详情(待付款)
      return OrderDetail(
        id: '10',
        orderNo: 'DDBH3456789',
        status: OrderStatus.pendingPayment,
        statusText: '待付款',
        orderType: OrderType.mall,
        items: [commonItem],
        address: commonAddress,
        productTotalCents: 80000,
        shippingFeeCents: 0,
        discountCents: 0,
        pointsDeductedCents: 0,
        payAmountCents: 80000,
        createTime: base,
        timeline: [OrderTimeline(time: DateTime(2026, 10, 10, 12, 0), title: '下单', desc: '下单成功', status: OrderStatus.pendingPayment)],
      );
    default:
      // 默认返回商城待付款
      return OrderDetail(
        id: id,
        orderNo: 'DDBH0000000',
        status: OrderStatus.pendingPayment,
        statusText: '待付款',
        orderType: OrderType.mall,
        items: [commonItem],
        address: commonAddress,
        productTotalCents: 80000,
        shippingFeeCents: 0,
        discountCents: 0,
        pointsDeductedCents: 0,
        payAmountCents: 80000,
        createTime: base,
        timeline: [OrderTimeline(time: DateTime(2026, 10, 10, 12, 0), title: '下单', desc: '下单成功', status: OrderStatus.pendingPayment)],
      );
  }
}
