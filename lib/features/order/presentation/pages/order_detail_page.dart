import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/order_list_order.dart';
import '../../domain/repositories/order_repository.dart';
import '../providers/order_detail_provider.dart';
import '../widgets/order_amount_text.dart';

/// 商城订单详情页。
///
/// 所有商城订单共用这一套布局，页面内容根据后端订单状态和非空字段变化。
class OrderDetailPage extends ConsumerWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(orderDetailProvider(orderId));
    return asyncDetail.when(
      data: (response) {
        if (!response.success || response.data == null) {
          return _StateScaffold(body: const Center(child: Text('订单不存在')));
        }
        return _OrderDetailScaffold(detail: response.data!);
      },
      loading: () => const _StateScaffold(body: Center(child: AppLoading())),
      error: (error, stackTrace) => const _StateScaffold(body: Center(child: Text('加载失败'))),
    );
  }
}

class _StateScaffold extends StatelessWidget {
  final Widget body;

  const _StateScaffold({required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: _OrderDetailTokens.pageBackground, appBar: _buildAppBar(context), body: body);
  }
}

class _OrderDetailScaffold extends StatelessWidget {
  final OrderDetail detail;

  const _OrderDetailScaffold({required this.detail});

  @override
  Widget build(BuildContext context) {
    final actions = _actionsFor(detail);
    return Scaffold(
      backgroundColor: _OrderDetailTokens.pageBackground,
      appBar: _buildAppBar(context),
      bottomNavigationBar: actions.isEmpty ? null : _BottomActionBar(actions: actions),
      body: _OrderDetailBody(detail: detail, hasBottomBar: actions.isNotEmpty),
    );
  }
}

PreferredSizeWidget _buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: _OrderDetailTokens.headerStart,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleSpacing: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 19),
      onPressed: () => context.pop(),
    ),
    title: const Text(
      '订单详情',
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.onSurface),
    ),
  );
}

class _OrderDetailTokens {
  static const pageBackground = Color(0xFFF3F5F7);
  static const headerStart = Color(0xFFE0E8FF);
  static const headerEnd = Color(0xFFF3F5F7);
  static const navy = Color(0xFF213775);
  static const muted = Color(0xFF8E8E97);
  static const divider = Color(0xFFE1E4DC);
  static const accent = Color(0xFFFF2105);
}

class _OrderDetailBody extends StatelessWidget {
  final OrderDetail detail;
  final bool hasBottomBar;

  const _OrderDetailBody({required this.detail, required this.hasBottomBar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.center, colors: [_OrderDetailTokens.headerStart, _OrderDetailTokens.headerEnd]),
      ),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _StatusHeader(detail: detail)),
          if (detail.timeline.isNotEmpty)
            SliverToBoxAdapter(child: _LogisticsCard(detail: detail))
          else if (_hasAddress(detail.address))
            SliverToBoxAdapter(child: _AddressCard(address: detail.address)),
          SliverToBoxAdapter(child: _OrderContentCard(detail: detail)),
          SliverToBoxAdapter(child: SizedBox(height: hasBottomBar ? 18 : 28)),
        ],
      ),
    );
  }

  bool _hasAddress(OrderAddress address) {
    return address.detail.isNotEmpty;
  }
}

class _StatusHeader extends StatelessWidget {
  final OrderDetail detail;

  const _StatusHeader({required this.detail});

  @override
  Widget build(BuildContext context) {
    final showPaymentHint = detail.backendStateCode == 30 && detail.waitPay;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 11, 16, 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/order/huaban.png',
                width: 46,
                height: 46,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2_outlined, size: 42, color: _OrderDetailTokens.navy),
              ),
              const SizedBox(width: 4),
              Text(
                detail.statusText.isEmpty ? '订单详情' : detail.statusText,
                style: const TextStyle(fontSize: 26, height: 1.15, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ],
          ),
          if (showPaymentHint) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: _OrderDetailTokens.navy.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(30)),
              child: const Text(
                '支付剩余时间',
                style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w400, color: _OrderDetailTokens.navy),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final OrderAddress address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    final region = [address.province, address.city, address.district].where((value) => value.isNotEmpty).join(' ');
    final detailText = address.detail.isNotEmpty ? address.detail : address.fullAddress;
    return _CardShell(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (region.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: _OrderDetailTokens.navy),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          region,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: _OrderDetailTokens.muted, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                if (detailText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    detailText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.3),
                  ),
                ],
                if (address.name.isNotEmpty || address.phone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    [address.name, address.phone].where((value) => value.isNotEmpty).join('   '),
                    style: const TextStyle(fontSize: 13, color: _OrderDetailTokens.muted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderContentCard extends StatelessWidget {
  final OrderDetail detail;

  const _OrderContentCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.fromLTRB(10, 13, 10, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < detail.items.length; index++) ...[
            _ProductRow(item: detail.items[index], isCredit: detail.isCreditOrder),
            if (index != detail.items.length - 1) const SizedBox(height: 12),
          ],
          if (detail.items.isNotEmpty) const SizedBox(height: 7),
          _AmountRow(label: '订单金额', value: _moneyOrPoints(detail.productTotalCents, detail.orderAmountDescription, detail.isCreditOrder), accent: true),
          const SizedBox(height: 8),
          _AmountRow(label: '订单运费', value: _money(detail.shippingFeeCents)),
          const SizedBox(height: 8),
          _AmountRow(label: '优惠券抵扣', value: '-${_money(detail.discountCents)}', accent: detail.discountCents != 0),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: _OrderDetailTokens.divider),
          ),
          _MetaRow(label: '订单编号', value: detail.orderNo),
          if (detail.paySerialNumber != null) _MetaRow(label: '交易单号', value: detail.paySerialNumber!),
          if (detail.payTypeName != null) _MetaRow(label: '支付方式', value: detail.payTypeName!),
          if ((detail.orderTypeLabel ?? '').isNotEmpty) _MetaRow(label: '订单类型', value: detail.orderTypeLabel!),
          if (_hasDate(detail.createTime)) _MetaRow(label: '下单时间', value: _formatDate(detail.createTime)),
          if (detail.payTime != null) _MetaRow(label: '付款时间', value: _formatDate(detail.payTime!)),
          if (detail.shipTime != null) _MetaRow(label: '发货时间', value: _formatDate(detail.shipTime!)),
          if (detail.receiveTime != null) _MetaRow(label: '收货时间', value: _formatDate(detail.receiveTime!)),
          if ((detail.remark ?? detail.userRemark ?? '').trim().isNotEmpty &&
              (detail.remark ?? detail.userRemark) != '【】')
            _MetaRow(label: '订单备注', value: (detail.remark ?? detail.userRemark!).trim()),
        ],
      ),
    );
  }

  bool _hasDate(DateTime date) => date.millisecondsSinceEpoch != 0;

  String _money(int cents) => '¥${(cents / 100).toStringAsFixed(2)}';

  String _moneyOrPoints(int cents, String? description, bool isCredit) {
    if (description != null && description.isNotEmpty && !description.startsWith('0')) return description;
    if (isCredit) return '$cents青稞粒';
    return _money(cents);
  }
}

class _ProductRow extends StatelessWidget {
  final OrderItem item;
  final bool isCredit;

  const _ProductRow({required this.item, required this.isCredit});

  @override
  Widget build(BuildContext context) {
    final tags = <String>[if (item.tag != null && item.tag!.isNotEmpty) item.tag!];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD8DBE4)),
            borderRadius: BorderRadius.circular(5),
          ),
          clipBehavior: Clip.antiAlias,
          child: AppNetworkImage(url: item.imageUrl, width: 100, height: 100, fit: BoxFit.cover),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black, height: 1.25),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 5),
                Wrap(spacing: 7, runSpacing: 4, children: [for (final tag in tags) _Tag(tag)]),
              ],
              if (_specTags(item.parameters).isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(spacing: 6, children: _specTags(item.parameters).map(_SpecTag.new).toList()),
              ],
            ],
          ),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _productAmount(item, isCredit),
            const SizedBox(height: 4),
            Text('×${item.quantity}', style: const TextStyle(fontSize: 12, color: _OrderDetailTokens.muted)),
          ],
        ),
      ],
    );
  }
}

Widget _productAmount(OrderItem item, bool isCredit) {
  final description = item.priceDescription;
  if (description != null && description.isNotEmpty && !description.startsWith('0')) {
    return _amountDescriptionText(description, mainFontSize: 16);
  }
  if (isCredit) {
    return _amountDescriptionTextWithColor('${item.totalCents}青稞粒', mainFontSize: 16, color: _OrderDetailTokens.accent);
  }
  if (item.totalCents > 0) {
    return _moneyText(item.totalCents, mainFontSize: 16);
  }
  return _amountDescriptionTextWithColor('${item.totalCents}青稞粒', mainFontSize: 16, color: _OrderDetailTokens.accent);
}

Widget _amountDescriptionText(String value, {required double mainFontSize}) {
  return OrderAmountText(value: value, mainFontSize: mainFontSize);
}

Widget _amountDescriptionTextWithColor(String value, {required double mainFontSize, required Color color}) {
  return OrderAmountText(value: value, mainFontSize: mainFontSize, color: color);
}

Widget _moneyText(int cents, {required double mainFontSize, Color color = AppColors.onSurface}) {
  final absolute = cents.abs();
  final prefix = cents < 0 ? '-¥' : '¥';
  return RichText(
    text: TextSpan(
      style: TextStyle(color: color),
      children: [
        TextSpan(
          text: prefix,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
        TextSpan(
          text: '${absolute ~/ 100}',
          style: TextStyle(fontSize: mainFontSize, fontWeight: FontWeight.w600, color: color),
        ),
        TextSpan(
          text: '.${absolute.remainder(100).toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    ),
  );
}

class _LogisticsCard extends StatelessWidget {
  final OrderDetail detail;

  const _LogisticsCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final latest = detail.timeline.isNotEmpty ? detail.timeline.last : null;
    final address = detail.address;
    return _CardShell(
      margin: const EdgeInsets.fromLTRB(14, 11, 14, 18),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(left: 1, right: 8),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: _OrderDetailTokens.accent),
              ),
              const Text(
                '已签收',
                style: TextStyle(fontSize: 22, height: 1.2, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              const Spacer(),
              const Row(
                children: [
                  Text('查看详情', style: TextStyle(fontSize: 14, color: _OrderDetailTokens.muted)),
                  Icon(Icons.chevron_right, size: 22, color: _OrderDetailTokens.muted),
                ],
              ),
            ],
          ),
          if (latest != null) ...[
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                latest.desc ?? latest.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, height: 1.45, color: _OrderDetailTokens.muted),
              ),
            ),
          ],
          if (address.detail.isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 1, top: 7, right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _OrderDetailTokens.accent, width: 1),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.detail,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                      ),
                      if (address.name.isNotEmpty || address.phone.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          [address.name, address.phone].where((value) => value.isNotEmpty).join('   '),
                          style: const TextStyle(fontSize: 14, color: _OrderDetailTokens.muted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Widget child;

  const _CardShell({required this.margin, required this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: child,
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: _OrderDetailTokens.accent),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, color: _OrderDetailTokens.accent)),
    );
  }
}

List<String> _specTags(List<OrderListParameter> parameters) {
  final values = <String, String>{for (final parameter in parameters) parameter.name.trim(): parameter.value.trim()};
  final degree = values['度数'];
  final flavor = values['香型'];
  return [if (degree != null && degree.isNotEmpty) _degreeLabel(degree), if (flavor != null && flavor.isNotEmpty) flavor];
}

String _degreeLabel(String value) {
  final trimmed = value.trim();
  if (trimmed.endsWith('°') || trimmed.endsWith('度')) {
    return '${trimmed.substring(0, trimmed.length - 1)}%vol';
  }
  return trimmed;
}

class _SpecTag extends StatelessWidget {
  final String label;

  const _SpecTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: _OrderDetailTokens.accent, width: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, color: _OrderDetailTokens.accent)),
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
        Text(label, style: const TextStyle(fontSize: 13, color: _OrderDetailTokens.muted)),
        _amountDescriptionTextWithColor(value, mainFontSize: bold ? 20 : 16, color: accent ? _OrderDetailTokens.accent : Colors.black),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _OrderDetailTokens.muted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: _OrderDetailTokens.muted, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final List<String> actions;

  const _BottomActionBar({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x18000000), blurRadius: 5, offset: Offset(0, -1))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (var index = 0; index < actions.length; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                _ActionButton(label: actions[index], primary: index == actions.length - 1),
              ],
              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool primary;

  const _ActionButton({required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        constraints: const BoxConstraints(minWidth: 96),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: primary
            ? const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF3152AF), Color(0xFF213775)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.all(Radius.circular(999)),
              )
            : const BoxDecoration(color: Color(0xFFF3F5F7), borderRadius: BorderRadius.all(Radius.circular(999))),
        child: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: primary ? FontWeight.w500 : FontWeight.w400, color: primary ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

List<String> _actionsFor(OrderDetail detail) {
  return switch (detail.backendStateCode) {
    30 => ['取消订单', detail.waitEndPay ? '支付尾款' : '立即付款'],
    90 => ['申请退款'],
    110 => ['申请退款', '确认收货'],
    130 || 140 => ['申请退款'],
    160 => ['取消售后'],
    _ => const <String>[],
  };
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
