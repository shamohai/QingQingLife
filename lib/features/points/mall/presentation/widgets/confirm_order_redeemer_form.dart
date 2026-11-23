import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_spacing.dart';

/// 兑换人/手机号接收信息表单（RecvrMobile）
class ConfirmOrderRedeemerForm extends StatefulWidget {
  /// 默认充值账号（接口 defaultrechargemobile），作为输入框初始值
  final String? initialPhone;
  final ValueChanged<String>? onPhoneChanged;
  final VoidCallback onSubmitted;

  const ConfirmOrderRedeemerForm({super.key, this.initialPhone, this.onPhoneChanged, required this.onSubmitted});

  @override
  State<ConfirmOrderRedeemerForm> createState() => _ConfirmOrderRedeemerFormState();
}

class _ConfirmOrderRedeemerFormState extends State<ConfirmOrderRedeemerForm> {
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final initialPhone = widget.initialPhone?.trim() ?? '';
    if (initialPhone.isNotEmpty) {
      _phoneController.text = initialPhone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 11 || !RegExp(r'^\d+$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入正确的11位手机号')));
      _phoneFocus.requestFocus();
      return;
    }
    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: AppSpacing.compactPageMargin, right: AppSpacing.compactPageMargin, top: AppSpacing.md),
      padding: const EdgeInsets.only(left: AppSpacing.xxl, top: AppSpacing.lg, bottom: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0xE6EAE8E9), blurRadius: 7, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '充值/接收手机号',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF213775)),
          ),
          const SizedBox(height: 10),
          _buildInputField(
            controller: _phoneController,
            focusNode: _phoneFocus,
            placeholder: '请输入手机号',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: widget.onPhoneChanged,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String placeholder,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF3F5F7), borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        minLines: null,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 16, color: Color(0xFF1F2024)),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: placeholder,
          hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF8E8E97)),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTapOutside: (_) => focusNode.unfocus(),
      ),
    );
  }
}
