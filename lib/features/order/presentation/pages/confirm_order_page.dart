import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../member/presentation/providers/member_addresses_provider.dart';
import '../models/confirm_order_invoice_draft.dart';
import '../providers/confirm_order_provider.dart';
import '../widgets/confirm_order/confirm_order_address_sheet.dart';
import '../widgets/confirm_order/confirm_order_amount_card.dart';
import '../widgets/confirm_order/confirm_order_bottom_bar.dart';
import '../widgets/confirm_order/confirm_order_coupon_sheet.dart';
import '../widgets/confirm_order/confirm_order_header.dart';
import '../widgets/confirm_order/confirm_order_invoice_info_page.dart';
import '../widgets/confirm_order/confirm_order_payment_card.dart';
import '../widgets/confirm_order/confirm_order_product_card.dart';
import 'mall_payment_success_page.dart';

class ConfirmOrderPage extends ConsumerStatefulWidget {
  const ConfirmOrderPage({super.key});

  @override
  ConsumerState<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends ConsumerState<ConfirmOrderPage> {
  late final TextEditingController _noteController;
  MallConfirmOrderInvoiceDraft? _invoiceInfoDraft;

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
              MallConfirmOrderHeader(address: state.address, onEditAddress: () => _showAddressSheet(context)),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                  child: Column(
                    children: [
                      MallConfirmOrderProductCard(
                        state: state,
                        noteController: _noteController,
                        onIncrement: () => ref.read(confirmOrderProvider.notifier).increment(),
                        onDecrement: () => ref.read(confirmOrderProvider.notifier).decrement(),
                        onNoteChanged: (value) => ref.read(confirmOrderProvider.notifier).setNote(value),
                      ),
                      const SizedBox(height: 10),
                      MallConfirmOrderAmountCard(state: state, onInvoiceTap: () => _showInvoicePage(context), onCouponTap: () => _showCouponSheet(context)),
                      const SizedBox(height: 10),
                      MallConfirmOrderPaymentCard(
                        selected: state.paymentMethod == '微信支付',
                        onTap: () => ref.read(confirmOrderProvider.notifier).setPaymentMethod('微信支付'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: MallConfirmOrderBottomBar(state: state, onSubmit: state.isSubmitting ? null : () => _submit(context)),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final response = await ref.read(confirmOrderProvider.notifier).submit();
    if (!context.mounted) return;
    if (response.success && response.data != null) {
      final state = ref.read(confirmOrderProvider);
      context.push(
        RouteNames.mallPaymentSuccess,
        extra: MallPaymentSuccessData(
          orderId: response.data!.orderId,
          orderNo: response.data!.orderNo,
          transactionNo: 'WX${DateTime.now().millisecondsSinceEpoch}',
          amountCents: state.payableCents,
          discountCents: state.couponDiscountCents,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message)));
    }
  }

  Future<void> _showAddressSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      barrierColor: const Color(0x4D000000),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        final height = (media.size.height - media.padding.top - 16).clamp(0.0, 648.0).toDouble();
        return SizedBox(
          height: height,
          child: MallConfirmOrderAddressSheet(
            selectedAddressId: ref.read(confirmOrderProvider).address.id,
            bottomInset: media.padding.bottom,
            onSelect: (address) {
              ref.read(confirmOrderProvider.notifier).setAddress(address);
              Navigator.of(sheetContext).pop();
            },
            onCreate: () async {
              Navigator.of(sheetContext).pop();
              await context.push(RouteNames.addressAdd);
              if (mounted) ref.invalidate(memberAddressesProvider);
            },
          ),
        );
      },
    );
  }

  Future<void> _showCouponSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      barrierColor: const Color(0x4D000000),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        final height = (media.size.height - media.padding.top).clamp(0.0, 675.0).toDouble();
        return SizedBox(
          height: height,
          child: MallConfirmOrderCouponSheet(
            bottomInset: media.padding.bottom,
            onUse: () {
              ref.read(confirmOrderProvider.notifier).selectCoupon(name: '新人券 ¥50.00', discountCents: 5000);
              Navigator.of(sheetContext).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> _showInvoicePage(BuildContext context) async {
    final saved = await Navigator.of(context).push<MallConfirmOrderInvoiceDraft>(
      MaterialPageRoute<MallConfirmOrderInvoiceDraft>(builder: (_) => MallConfirmOrderInvoiceInfoPage(initialValue: _invoiceInfoDraft)),
    );
    if (saved != null && mounted) {
      _invoiceInfoDraft = saved;
      ref.read(confirmOrderProvider.notifier).setNeedInvoice(true);
    }
  }
}
