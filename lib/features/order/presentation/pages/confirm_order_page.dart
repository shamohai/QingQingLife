import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../member/domain/repositories/member_repository.dart';
import '../providers/confirm_order_provider.dart';

class ConfirmOrderPage extends ConsumerStatefulWidget {
  const ConfirmOrderPage({super.key});

  @override
  ConsumerState<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends ConsumerState<ConfirmOrderPage> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: ref.read(confirmOrderProvider).note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(confirmOrderProvider);
    final baseTheme = Theme.of(context);
    const fallbackFonts = ['PingFang SC', 'Microsoft YaHei UI', 'Microsoft YaHei', 'Noto Sans CJK SC', 'sans-serif'];
    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'PingFang HK', fontFamilyFallback: fallbackFonts),
        primaryTextTheme: baseTheme.primaryTextTheme.apply(fontFamily: 'PingFang HK', fontFamilyFallback: fallbackFonts),
      ),
      child: Scaffold(
        backgroundColor: AppColors.servicePageBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(address: state.address, onEditAddress: () => _showAddressSheet(context)),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                  child: Column(
                    children: [
                      _ProductCard(
                        state: state,
                        noteController: _noteController,
                        onIncrement: () => ref.read(confirmOrderProvider.notifier).increment(),
                        onDecrement: () => ref.read(confirmOrderProvider.notifier).decrement(),
                        onNoteChanged: (value) => ref.read(confirmOrderProvider.notifier).setNote(value),
                      ),
                      const SizedBox(height: 10),
                      _AmountCard(
                        state: state,
                        onInvoiceChanged: (value) => ref.read(confirmOrderProvider.notifier).setNeedInvoice(value),
                        onCouponTap: () => _showCouponSheet(context),
                      ),
                      const SizedBox(height: 10),
                      _PaymentCard(selected: state.paymentMethod == '微信支付', onTap: () => ref.read(confirmOrderProvider.notifier).setPaymentMethod('微信支付')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomBar(state: state, onSubmit: state.isSubmitting ? null : () => _submit(context)),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final response = await ref.read(confirmOrderProvider.notifier).submit();
    if (!context.mounted) return;
    if (response.success && response.data != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('订单提交成功')));
      context.push('/orders/${response.data!.orderId}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message)));
    }
  }

  Future<void> _showAddressSheet(BuildContext context) async {
    const addresses = [
      MemberAddress(id: 'addr_1', name: '吴彦祖', phone: '130 9876 9987', province: '甘肃省', city: '兰州市', district: '七里河区', detail: '兰州中心办公楼801室', isDefault: true),
      MemberAddress(id: 'addr_2', name: '吴彦祖', phone: '130 9876 9987', province: '青海省', city: '西宁市', district: '城西区', detail: '文汇路街道青轻生活馆'),
    ];
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('选择收货地址', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...addresses.map(
                (address) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${address.name}  ${address.phone}'),
                  subtitle: Text(address.fullAddress),
                  trailing: address.id == ref.read(confirmOrderProvider).address.id ? const Icon(Icons.check_circle, color: Color(0xFF213775)) : null,
                  onTap: () {
                    ref.read(confirmOrderProvider.notifier).setAddress(address);
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCouponSheet(BuildContext context) async {
    final selected = ref.read(confirmOrderProvider).couponName != null;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('选择优惠券', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('新人券 ¥50.00'),
                subtitle: const Text('全场商品可用'),
                trailing: selected ? const Icon(Icons.check_circle, color: Color(0xFF213775)) : null,
                onTap: () {
                  ref.read(confirmOrderProvider.notifier).selectCoupon(name: '新人券 ¥50.00', discountCents: 5000);
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('不使用优惠券'),
                trailing: !selected ? const Icon(Icons.check_circle, color: Color(0xFF213775)) : null,
                onTap: () {
                  ref.read(confirmOrderProvider.notifier).clearCoupon();
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.address, required this.onEditAddress});

  final MemberAddress address;
  final VoidCallback onEditAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Exclude the mockup's 50px system status bar; SafeArea supplies it.
      height: 153,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 6, bottom: 17),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 27,
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Row(
                children: [
                  GestureDetector(onTap: () => context.pop(), child: Image.asset('assets/images/order/confirm-order-back.png', width: 24, height: 24)),
                  const Text(
                    '确认订单',
                    style: TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 21,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Image.asset('assets/images/points/confirm_order_location.png', width: 17, height: 20),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${address.province} ${address.city} ${address.district} 建兰路街道',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF8E8E93)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 27,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      address.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: onEditAddress,
                    child: const Text('修改地址>', style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF213775))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 21,
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text('${address.name}   ${address.phone}', style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.state, required this.noteController, required this.onIncrement, required this.onDecrement, required this.onNoteChanged});

  final ConfirmOrderState state;
  final TextEditingController noteController;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<String> onNoteChanged;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      height: 172,
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 13),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.asset(state.product.imageUrl, width: 70, height: 70, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.product.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.product.skuName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, height: 1.2, color: Color(0xFF8E8E93)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(state.product.priceCents),
                      style: const TextStyle(fontSize: 20, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.serviceButtonRed),
                    ),
                    const Text('¥900.00', style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF8E8E93))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: _QuantityStepper(quantity: state.quantity, onIncrement: onIncrement, onDecrement: onDecrement),
          ),
          const Spacer(),
          Row(
            children: [
              const Text('留言备注', style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
              const Spacer(),
              SizedBox(
                width: 133,
                height: 24,
                child: TextField(
                  controller: noteController,
                  onChanged: onNoteChanged,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  decoration: const InputDecoration(
                    hintText: '请填写备注信息 >',
                    hintStyle: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF8E8E93)),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.state, required this.onInvoiceChanged, required this.onCouponTap});

  final ConfirmOrderState state;
  final ValueChanged<bool> onInvoiceChanged;
  final VoidCallback onCouponTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      height: 217,
      padding: const EdgeInsets.fromLTRB(11, 14, 11, 18),
      child: Column(
        children: [
          _SummaryRow(label: '是否需要发票', value: state.needInvoice ? '已选择 >' : '去开票 >', onTap: () => onInvoiceChanged(!state.needInvoice)),
          const SizedBox(height: 10),
          _SummaryRow(label: '商品总价', value: _money(state.productTotalCents), valueColor: const Color(0xFFFF2105)),
          const SizedBox(height: 10),
          _SummaryRow(label: '运费', value: _money(state.shippingFeeCents), valueColor: Colors.black),
          const SizedBox(height: 10),
          _SummaryRow(label: '选择优惠券', value: state.couponName == null ? '暂无可用券 >' : '${state.couponName}  >', onTap: onCouponTap),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE3E8F0)),
          const SizedBox(height: 15),
          _SummaryRow(label: '合计金额', value: _money(state.payableCents), labelWeight: FontWeight.w500, valueColor: const Color(0xFFFF2105), valueSize: 18),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _Panel(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Image.asset('assets/images/order/confirm-order-wechat.png', width: 26, height: 26),
            const SizedBox(width: 10),
            const Text(
              '微信支付',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (selected) Image.asset('assets/images/order/confirm-order-selected.png', width: 20, height: 20),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state, required this.onSubmit});

  final ConfirmOrderState state;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final amount = _money(state.payableCents).substring(1).split('.');
    return Container(
      height: 80 + MediaQuery.paddingOf(context).bottom,
      padding: EdgeInsets.fromLTRB(20, 13, 12, MediaQuery.paddingOf(context).bottom + 13),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Keep the amount on one line on narrow phones; the source layout
                // assumes a wider frame, so scale only this compact summary when needed.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: RichText(
                    maxLines: 1,
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style.copyWith(color: Colors.black, fontSize: 14, height: 1),
                      children: [
                        const TextSpan(text: '合计：'),
                        const TextSpan(
                          text: '¥',
                          style: TextStyle(color: Color(0xFFFE273D), fontSize: 16, height: 1, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: '${amount.first}.',
                          style: const TextStyle(color: Color(0xFFFE273D), fontSize: 24, height: 1, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: amount.last,
                          style: const TextStyle(color: Color(0xFFFE273D), fontSize: 16, height: 1, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('共减免${(state.couponDiscountCents / 100).toStringAsFixed(0)}元', style: const TextStyle(fontSize: 12, color: Color(0xFFFF2105))),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 156,
            height: 47,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.serviceTabActive, AppColors.serviceCtaGradStart]),
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextButton(
                onPressed: onSubmit,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  state.isSubmitting ? '提交中...' : '提交订单',
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.height, required this.child, this.padding = const EdgeInsets.all(10)});

  final double height;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: child,
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onIncrement, required this.onDecrement});

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 24,
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/order/confirm-order-minus.png'), fit: BoxFit.fill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(label: '−', onTap: onDecrement),
          SizedBox(
            width: 20,
            child: Center(
              child: Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
          _StepperButton(label: '+', onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 20,
        height: 24,
        child: Center(
          child: Text(label, style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.onTap,
    this.valueColor = const Color(0xFF8E8E93),
    this.valueSize = 16,
    this.labelWeight = FontWeight.w400,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final Color valueColor;
  final double valueSize;
  final FontWeight labelWeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        // Lock the design row height. Web CJK fonts can report a line box about
        // one pixel taller than fontSize * height, which accumulated across the
        // five rows and overflowed the fixed-height amount card.
        height: valueSize > 16 ? 27 : 24,
        child: Row(
          children: [
            Text(
              label,
              maxLines: 1,
              style: TextStyle(fontSize: 16, height: 1.5, fontWeight: labelWeight, color: Colors.black),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: valueSize,
                  height: 1.5,
                  color: valueColor,
                  fontWeight: valueColor == AppColors.serviceButtonRed || valueColor == Colors.black ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _money(int cents) => '¥${(cents / 100).toStringAsFixed(2)}';
