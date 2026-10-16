import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_spacing.dart';

/// 礼品卡（giftCard）兑换人信息表单。
///
/// 包含「兑换人姓名」和「手机号」两个输入项，提交时校验并触发 [onSubmitted]。
class ConfirmOrderRedeemerForm extends StatefulWidget {
  final VoidCallback onSubmitted;

  const ConfirmOrderRedeemerForm({super.key, required this.onSubmitted});

  @override
  State<ConfirmOrderRedeemerForm> createState() => _ConfirmOrderRedeemerFormState();
}

class _ConfirmOrderRedeemerFormState extends State<ConfirmOrderRedeemerForm> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocus.unfocus();
    _phoneFocus.unfocus();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入兑换人姓名')));
      _nameFocus.requestFocus();
      return;
    }
    if (phone.isEmpty || phone.length != 11 || !RegExp(r'^\d+$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入正确的手机号')));
      _phoneFocus.requestFocus();
      return;
    }
    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: AppSpacing.md),
      padding: const EdgeInsets.only(left: AppSpacing.xxl, top: AppSpacing.lg, bottom: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white, // ← 外层白色保留
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: const Color(0xE6EAE8E9), blurRadius: 7, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '兑换人',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF213775)),
          ),
          const SizedBox(height: 10),
          _buildInputField(controller: _nameController, focusNode: _nameFocus, placeholder: '请输入兑换人姓名'),
          const SizedBox(height: 16),
          const Text(
            '手机号',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF213775)),
          ),
          const SizedBox(height: 10),
          _buildInputField(
            controller: _phoneController,
            focusNode: _phoneFocus,
            placeholder: '请输入手机号',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF3F5F7), borderRadius: BorderRadius.circular(8)),
      // 去掉 Align，让 TextField 自己撑满高度再居中
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
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
        onSubmitted: onSubmitted,
        onTapOutside: (_) => focusNode.unfocus(),
      ),
    );
  }
}
