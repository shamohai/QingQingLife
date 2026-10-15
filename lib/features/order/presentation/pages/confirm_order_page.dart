import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../member/domain/repositories/member_repository.dart';
import '../../../member/presentation/providers/member_addresses_provider.dart';
import '../providers/confirm_order_provider.dart';
import 'mall_payment_success_page.dart';

class ConfirmOrderPage extends ConsumerStatefulWidget {
  const ConfirmOrderPage({super.key});

  @override
  ConsumerState<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

typedef _InvoiceInfoDraft = ({
  String? invoiceType,
  String title,
  String taxId,
  String? registrationAddress,
  String phone,
  String bank,
  String bankAccount,
  bool isCompany,
});

class _ConfirmOrderPageState extends ConsumerState<ConfirmOrderPage> {
  late final TextEditingController _noteController;
  _InvoiceInfoDraft? _invoiceInfoDraft;

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
                      _AmountCard(state: state, onInvoiceTap: () => _showInvoicePage(context), onCouponTap: () => _showCouponSheet(context)),
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
          child: _AddressSheet(
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
          child: _CouponSheet(
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
    final saved = await Navigator.of(context)
        .push<_InvoiceInfoDraft>(MaterialPageRoute<_InvoiceInfoDraft>(builder: (_) => _InvoiceInfoPage(initialValue: _invoiceInfoDraft)));
    if (saved != null && mounted) {
      _invoiceInfoDraft = saved;
      ref.read(confirmOrderProvider.notifier).setNeedInvoice(true);
    }
  }
}

class _CouponSheet extends StatelessWidget {
  const _CouponSheet({required this.bottomInset, required this.onUse});

  final double bottomInset;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 17, 14, 0),
          child: SizedBox(
            height: 29,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text('选择优惠券', style: TextStyle(fontSize: 20, height: 1.4, color: Colors.black)),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '关闭',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    icon: Image.asset('assets/images/order/confirm-order-coupon-close.png', width: 24, height: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: _CouponCard(available: true, onUse: onUse),
        ),
        const SizedBox(height: 12),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: _CouponCard(available: false)),
        SizedBox(height: bottomInset),
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.available, this.onUse});

  final bool available;
  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) {
    final color = available ? const Color(0xFFFF2105) : const Color(0xFF8E8E93);
    return SizedBox(
      height: 110,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              available ? 'assets/images/order/confirm-order-coupon-available.png' : 'assets/images/order/confirm-order-coupon-unavailable.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: color, fontFamily: 'PingFang HK', fontWeight: FontWeight.w600),
                      children: const [
                        TextSpan(text: '¥', style: TextStyle(fontSize: 16, height: 1)),
                        TextSpan(text: '50', style: TextStyle(fontSize: 32, height: 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('新人优惠券', style: TextStyle(fontSize: 14, height: 1.4, color: color)),
                ],
              ),
            ),
            Container(width: 1, height: 65, color: available ? const Color(0xFFFF5D18) : color),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '新人优惠券50元',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w500, color: color),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '有效期:2026.6.7—2026.10.1',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, height: 1.4, color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: available ? 84 : 82,
              height: 30,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: available ? null : const Color(0xFFC6C6C6),
                  gradient: available
                      ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFF5D18), Color(0xFFFF9147)])
                      : null,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TextButton(
                  onPressed: available ? onUse : null,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, disabledForegroundColor: Colors.white, shape: const StadiumBorder()),
                  child: Text(available ? '使用' : '不可用', style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class _InvoiceInfoPage extends StatefulWidget {
  const _InvoiceInfoPage({this.initialValue});

  final _InvoiceInfoDraft? initialValue;

  @override
  State<_InvoiceInfoPage> createState() => _InvoiceInfoPageState();
}

class _InvoiceInfoPageState extends State<_InvoiceInfoPage> {
  static const _invoiceTypes = ['增值税普通发票', '增值税专用发票'];
  static const _registrationAddresses = ['甘肃省兰州市七里河区'];

  late final TextEditingController _titleController;
  late final TextEditingController _taxIdController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bankController;
  late final TextEditingController _bankAccountController;
  String? _invoiceType;
  String? _registrationAddress;
  bool _isCompany = true;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    _titleController = TextEditingController(text: initialValue?.title ?? '');
    _taxIdController = TextEditingController(text: initialValue?.taxId ?? '');
    _phoneController = TextEditingController(text: initialValue?.phone ?? '');
    _bankController = TextEditingController(text: initialValue?.bank ?? '');
    _bankAccountController = TextEditingController(text: initialValue?.bankAccount ?? '');
    _invoiceType = initialValue?.invoiceType;
    _registrationAddress = initialValue?.registrationAddress;
    _isCompany = initialValue?.isCompany ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _taxIdController.dispose();
    _phoneController.dispose();
    _bankController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  Future<void> _chooseValue({required String title, required List<String> options, required ValueChanged<String> onSelected}) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ),
            for (final option in options) ListTile(title: Text(option), onTap: () => Navigator.of(context).pop(option)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (value != null) onSelected(value);
  }

  void _save() {
    // 静态预览保存本地草稿，未填写完整也可以返回确认订单。
    Navigator.of(context).pop<_InvoiceInfoDraft>((
      invoiceType: _invoiceType,
      title: _titleController.text.trim(),
      taxId: _taxIdController.text.trim(),
      registrationAddress: _registrationAddress,
      phone: _phoneController.text.trim(),
      bank: _bankController.text.trim(),
      bankAccount: _bankAccountController.text.trim(),
      isCompany: _isCompany,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 620),
                  padding: const EdgeInsets.only(bottom: 36),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 33,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Image.asset('assets/images/order/confirm-order-back.png', width: 24, height: 24),
                              ),
                              const Text(
                                '发票信息',
                                style: TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w500, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      _InvoiceSelectRow(
                        label: '选择发票类型',
                        value: _invoiceType,
                        placeholder: '请选择发票类型',
                        onTap: () => _chooseValue(title: '选择发票类型', options: _invoiceTypes, onSelected: (value) => setState(() => _invoiceType = value)),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 23),
                        child: SizedBox(
                          height: 24,
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text('开票人类型', style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
                              ),
                              _InvoiceTypeChoice(label: '企业', selected: _isCompany, onTap: () => setState(() => _isCompany = true)),
                              const SizedBox(width: 12),
                              _InvoiceTypeChoice(label: '个人', selected: !_isCompany, onTap: () => setState(() => _isCompany = false)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _InvoiceInputRow(label: '发票抬头', placeholder: '请输入发票抬头', controller: _titleController),
                      if (_isCompany) ...[
                        const SizedBox(height: 20),
                        _InvoiceInputRow(label: '纳税人识别号', placeholder: '请输入纳税人识别号', controller: _taxIdController),
                        const SizedBox(height: 20),
                        _InvoiceSelectRow(
                          label: '注册地址',
                          value: _registrationAddress,
                          placeholder: '请选择注册地址',
                          onTap: () => _chooseValue(
                            title: '选择注册地址',
                            options: _registrationAddresses,
                            onSelected: (value) => setState(() => _registrationAddress = value),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _InvoiceInputRow(label: '注册电话', placeholder: '请输入注册电话', controller: _phoneController, keyboardType: TextInputType.phone),
                        const SizedBox(height: 20),
                        _InvoiceInputRow(label: '开户银行', placeholder: '请输入开户银行', controller: _bankController),
                        const SizedBox(height: 20),
                        _InvoiceInputRow(label: '银行账户', placeholder: '请输入银行账户', controller: _bankAccountController, keyboardType: TextInputType.number),
                      ],
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 31),
                        child: SizedBox(
                          width: double.infinity,
                          height: 51,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [Color(0xFF3152AF), Color(0xFF213775)],
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: TextButton(
                              onPressed: _save,
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, shape: const StadiumBorder()),
                              child: const Text(
                                '确定保存',
                                style: TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w500, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceInputRow extends StatelessWidget {
  const _InvoiceInputRow({required this.label, required this.placeholder, required this.controller, this.keyboardType});

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fieldWidth = (constraints.maxWidth - 116).clamp(0.0, 278.0).toDouble();
          return Row(
            children: [
              SizedBox(
                width: 96,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: fieldWidth,
                height: 40,
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF8E8E93)),
                    filled: true,
                    fillColor: AppColors.servicePageBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InvoiceSelectRow extends StatelessWidget {
  const _InvoiceSelectRow({required this.label, required this.value, required this.placeholder, required this.onTap});

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fieldWidth = (constraints.maxWidth - 116).clamp(0.0, 278.0).toDouble();
          return Row(
            children: [
              SizedBox(
                width: 96,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: fieldWidth,
                height: 40,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.servicePageBackground, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            value ?? placeholder,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, height: 1.5, color: value == null ? const Color(0xFF8E8E93) : Colors.black),
                          ),
                        ),
                        const Icon(Icons.expand_more, size: 24, color: Color(0xFF8E8E93)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InvoiceTypeChoice extends StatelessWidget {
  const _InvoiceTypeChoice({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: selected ? const Color(0xFF168BFA) : const Color(0xFF8E8E93)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 16, height: 1.5, color: selected ? Colors.black : const Color(0xFF8E8E93))),
          ],
        ),
      ),
    );
  }
}

class _AddressSheet extends ConsumerWidget {
  const _AddressSheet({required this.selectedAddressId, required this.bottomInset, required this.onSelect, required this.onCreate});

  final String? selectedAddressId;
  final double bottomInset;
  final ValueChanged<MemberAddress> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(memberAddressesProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
          child: SizedBox(
            height: 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text('收货地址', style: TextStyle(fontSize: 20, height: 1.4, color: Colors.black)),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '关闭',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    icon: const Icon(Icons.close, size: 28, color: Color(0xFF303030)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: addresses.when(
            data: (items) => items.isEmpty
                ? const Center(child: Text('暂无收货地址', style: TextStyle(fontSize: 16)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final address = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AddressChoice(address: address, selected: address.id == selectedAddressId, onTap: () => onSelect(address)),
                      );
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: TextButton(onPressed: () => ref.invalidate(memberAddressesProvider), child: const Text('地址加载失败，点击重试')),
            ),
          ),
        ),
        Container(
          height: 80,
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 51,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.serviceTabActive, AppColors.serviceCtaGradStart],
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextButton(
                onPressed: onCreate,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, shape: const StadiumBorder()),
                child: const Text(
                  '创建新地址',
                  style: TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: bottomInset),
      ],
    );
  }
}

class _AddressChoice extends StatelessWidget {
  const _AddressChoice({required this.address, required this.selected, required this.onTap});

  final MemberAddress address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 98),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.serviceProjectBlue : Colors.transparent),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 2,
                    children: [
                      Text(
                        address.name,
                        style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500, color: selected ? AppColors.serviceTabActive : Colors.black),
                      ),
                      Text(
                        address.phone.replaceAll(' ', ''),
                        style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500, color: selected ? AppColors.serviceTabActive : Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(address.fullAddress, style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.black)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? AppColors.serviceProjectBlue : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.serviceProjectBlue : const Color(0xFF8E8E93)),
              ),
              child: selected ? const Icon(Icons.check, size: 22, color: Colors.white) : null,
            ),
          ],
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
  const _AmountCard({required this.state, required this.onInvoiceTap, required this.onCouponTap});

  final ConfirmOrderState state;
  final VoidCallback onInvoiceTap;
  final VoidCallback onCouponTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      height: 217,
      padding: const EdgeInsets.fromLTRB(11, 14, 11, 18),
      child: Column(
        children: [
          _SummaryRow(label: '是否需要发票', value: state.needInvoice ? '已保存 >' : '去开票 >', onTap: onInvoiceTap),
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
            Expanded(
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
