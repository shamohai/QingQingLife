import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../models/confirm_order_invoice_draft.dart';
import 'confirm_order_invoice_fields.dart';

/// 发票信息页：保存后把 [MallConfirmOrderInvoiceDraft] 通过 pop 返回确认订单页。
class MallConfirmOrderInvoiceInfoPage extends StatefulWidget {
  const MallConfirmOrderInvoiceInfoPage({super.key, this.initialValue});

  final MallConfirmOrderInvoiceDraft? initialValue;

  @override
  State<MallConfirmOrderInvoiceInfoPage> createState() => _MallConfirmOrderInvoiceInfoPageState();
}

class _MallConfirmOrderInvoiceInfoPageState extends State<MallConfirmOrderInvoiceInfoPage> {
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
    Navigator.of(context).pop<MallConfirmOrderInvoiceDraft>((
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
                      MallConfirmOrderInvoiceSelectRow(
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
                              MallConfirmOrderInvoiceTypeChoice(label: '企业', selected: _isCompany, onTap: () => setState(() => _isCompany = true)),
                              const SizedBox(width: 12),
                              MallConfirmOrderInvoiceTypeChoice(label: '个人', selected: !_isCompany, onTap: () => setState(() => _isCompany = false)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      MallConfirmOrderInvoiceInputRow(label: '发票抬头', placeholder: '请输入发票抬头', controller: _titleController),
                      if (_isCompany) ...[
                        const SizedBox(height: 20),
                        MallConfirmOrderInvoiceInputRow(label: '纳税人识别号', placeholder: '请输入纳税人识别号', controller: _taxIdController),
                        const SizedBox(height: 20),
                        MallConfirmOrderInvoiceSelectRow(
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
                        MallConfirmOrderInvoiceInputRow(label: '注册电话', placeholder: '请输入注册电话', controller: _phoneController, keyboardType: TextInputType.phone),
                        const SizedBox(height: 20),
                        MallConfirmOrderInvoiceInputRow(label: '开户银行', placeholder: '请输入开户银行', controller: _bankController),
                        const SizedBox(height: 20),
                        MallConfirmOrderInvoiceInputRow(
                          label: '银行账户',
                          placeholder: '请输入银行账户',
                          controller: _bankAccountController,
                          keyboardType: TextInputType.number,
                        ),
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
