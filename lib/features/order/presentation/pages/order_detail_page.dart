import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/enums/order_type.dart';
import '../../domain/repositories/order_repository.dart';
import '../providers/order_detail_provider.dart';
import 'service_order_detail_page.dart';
import 'points_order_detail_page.dart';
import 'points_pending_shipment_order_detail_page.dart';
import 'points_shipped_order_detail_page.dart';
import 'points_virtual_order_detail_page.dart';
import 'mall_completed_order_detail_page.dart';
import 'mall_pending_review_order_detail_page.dart';
import 'mall_shipped_order_detail_page.dart';
import 'mall_pending_shipment_order_detail_page.dart';
import 'mall_pending_payment_order_detail_page.dart';

/// 订单详情页
///
/// 路由参数: id (String) → detail_1 ~ detail_10
class OrderDetailPage extends ConsumerWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(mockOrderDetailByIdProvider(orderId));

    return asyncDetail.when(
      data: (response) {
        if (!response.success || response.data == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF3F5F7),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              titleSpacing: 0,
              title: const Text(
                '订单详情',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(child: Text('订单不存在')),
          );
        }
        final detail = response.data!;
        if (detail.orderType == OrderType.service) {
          return ServiceOrderDetailPage(orderId: orderId);
        }
        if (detail.orderType == OrderType.points) {
          if (orderId == '4') {
            return PointsVirtualOrderDetailPage(orderId: orderId);
          }
          if (detail.status == OrderStatus.pendingShipment) {
            return PointsPendingShipmentOrderDetailPage(orderId: orderId);
          }
          if (detail.status == OrderStatus.shipped) {
            return PointsShippedOrderDetailPage(orderId: orderId);
          }
          return PointsOrderDetailPage(orderId: orderId);
        }
        if (detail.orderType == OrderType.mall) {
          if (orderId == '10' || detail.status == OrderStatus.pendingPayment) {
            return MallPendingPaymentOrderDetailPage(orderId: orderId);
          }
          if (orderId == '9' || detail.status == OrderStatus.pendingShipment) {
            return MallPendingShipmentOrderDetailPage(orderId: orderId);
          }
          if (orderId == '8' || detail.status == OrderStatus.shipped) {
            return MallShippedOrderDetailPage(orderId: orderId);
          }
          if (orderId == '7' || orderId == '5' || detail.statusText == '待评价') {
            return MallPendingReviewOrderDetailPage(orderId: orderId);
          }
          if (detail.status == OrderStatus.completed) {
            return MallCompletedOrderDetailPage(orderId: orderId);
          }
        }
        return _OrderDetailPageScaffold(detail: detail);
      },
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFF3F5F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 0,
          title: const Text(
            '订单详情',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: AppLoading()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: const Color(0xFFF3F5F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 0,
          title: const Text(
            '订单详情',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('加载失败')),
      ),
    );
  }
}

class _OrderDetailPageScaffold extends StatelessWidget {
  final OrderDetail detail;

  const _OrderDetailPageScaffold({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          '订单详情',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: _OrderDetailBody(detail: detail),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  final OrderDetail detail;

  const _OrderDetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final isPoints = detail.orderType == OrderType.points;
    final isService = detail.orderType == OrderType.service;

    return CustomScrollView(
      slivers: [
        // 状态 Banner
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Text(
                  detail.statusText,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFFFF2105)),
                ),
                const SizedBox(height: 4),
                Text(_statusDesc(detail.status), style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E97))),
              ],
            ),
          ),
        ),
        // 订单编号
        SliverToBoxAdapter(
          child: _InfoCard(
            title:
                '${isPoints
                    ? '积分订单编号'
                    : isService
                    ? '服务订单编号'
                    : '商城订单编号'}：${detail.orderNo}',
            subtitle: '创建时间：${_formatDate(detail.createTime)}',
          ),
        ),
        // 商品信息
        SliverToBoxAdapter(
          child: _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: detail.items.map((item) => _ProductRow(item: item)).toList(),
            ),
          ),
        ),
        // 收货地址
        SliverToBoxAdapter(
          child: _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF213775)),
                    const SizedBox(width: 4),
                    Text(
                      '${detail.address.province}${detail.address.city}${detail.address.district}',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E97)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${detail.address.name}  ${detail.address.phone}\n${detail.address.detail}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        // 订单金额明细
        SliverToBoxAdapter(
          child: _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isPoints) ...[
                  _AmountRow(label: '商品总价', value: '¥${(detail.productTotalCents / 100).toStringAsFixed(2)}'),
                  const Divider(height: 1),
                  _AmountRow(label: '运费', value: '¥${(detail.shippingFeeCents / 100).toStringAsFixed(2)}'),
                  if (detail.discountCents > 0) ...[
                    const Divider(height: 1),
                    _AmountRow(label: '优惠', value: '-¥${(detail.discountCents / 100).toStringAsFixed(2)}', accent: true),
                  ],
                  const Divider(height: 1),
                  _AmountRow(label: '实付金额', value: '¥${(detail.payAmountCents / 100).toStringAsFixed(2)}', bold: true),
                ] else ...[
                  _AmountRow(label: '消耗积分', value: '${detail.pointsCost ?? 0}积分', bold: true),
                ],
              ],
            ),
          ),
        ),
        // 取件码（如有）
        if (detail.pickupCode != null)
          SliverToBoxAdapter(
            child: _InfoCard(
              child: Row(
                children: [
                  const Text('取件码：', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E97))),
                  const Spacer(),
                  Text(
                    detail.pickupCode!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF213775)),
                  ),
                ],
              ),
            ),
          ),
        // 操作按钮
        SliverToBoxAdapter(
          child: Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl), child: _buildActions(context)),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final status = detail.status;
    final type = detail.orderType ?? OrderType.mall;

    // 根据不同状态和类型返回不同按钮
    switch (type) {
      case OrderType.mall:
        switch (status) {
          case OrderStatus.pendingPayment:
            return _actionRow([_actionButton(context, '取消订单', false), _actionButton(context, '立即付款', true)]);
          case OrderStatus.pendingShipment:
            return _actionRow([_actionButton(context, '申请退款', false), _actionButton(context, '修改地址', false)]);
          case OrderStatus.shipped:
            return _actionRow([_actionButton(context, '申请退款', false), _actionButton(context, '确认收货', true)]);
          case OrderStatus.completed:
            return _actionRow([_actionButton(context, '申请退款', false), _actionButton(context, '去评价', true)]);
          default:
            return _actionRow([_actionButton(context, '再次购买', true)]);
        }
      case OrderType.points:
        switch (status) {
          case OrderStatus.pendingShipment:
          case OrderStatus.shipped:
            return _actionCenterButton(context, '修改地址');
          case OrderStatus.completed:
            return _actionCenterButton(context, '查看物流');
          default:
            return _actionCenterButton(context, '修改地址');
        }
      case OrderType.service:
        switch (status) {
          case OrderStatus.shipped:
            return _actionCenterButton(context, '立即核销');
          case OrderStatus.completed:
            return _actionCenterButton(context, '订单详情');
          default:
            return _actionCenterButton(context, '联系客服');
        }
    }
  }

  Widget _actionButton(BuildContext context, String label, bool primary) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.only(right: AppSpacing.md),
          height: 44,
          decoration: primary
              ? BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3152AF), Color(0xFF213775)]),
                  borderRadius: BorderRadius.circular(999),
                )
              : BoxDecoration(color: const Color(0xFFF3F5F7), borderRadius: BorderRadius.circular(999)),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: primary ? FontWeight.w500 : FontWeight.w400, color: primary ? Colors.white : AppColors.onSurface),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionCenterButton(BuildContext context, String label) {
    return Center(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 44,
          width: 200,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF3152AF), Color(0xFF213775)]),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionRow(List<Widget> children) {
    return Row(children: children);
  }

  String _statusDesc(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingPayment:
        return '付款后预计今天发货';
      case OrderStatus.pendingShipment:
        return '打包中，预计三天后到达';
      case OrderStatus.shipped:
        return '取件码：${detail.pickupCode ?? "待定"}';
      case OrderStatus.completed:
        return '商品已签收！如有疑问请联系客服';
      default:
        return '';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── 子组件 ───────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? child;

  const _InfoCard({this.title, this.subtitle, this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF213775)),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final OrderItem item;

  const _ProductRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: AppNetworkImage(url: item.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                item.skuName,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E97)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (item.totalCents > 0)
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurface),
                  children: [
                    TextSpan(text: '¥', style: const TextStyle(fontSize: 12)),
                    TextSpan(text: '${(item.totalCents / 100).toInt()}', style: const TextStyle(fontSize: 16)),
                    TextSpan(text: '.00', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              )
            else
              Text(
                '${item.totalCents}积分',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
              ),
            const SizedBox(height: 4),
            Text('×${item.quantity}', style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E97))),
          ],
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;
  final bool bold;

  const _AmountRow({required this.label, required this.value, this.accent = false, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E97))),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: accent ? const Color(0xFFFF2105) : AppColors.onSurface),
        ),
      ],
    );
  }
}
