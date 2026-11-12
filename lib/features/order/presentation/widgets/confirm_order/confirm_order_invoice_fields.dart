import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

/// 发票信息页的文本输入行（标签 + 输入框）。
class MallConfirmOrderInvoiceInputRow extends StatelessWidget {
  const MallConfirmOrderInvoiceInputRow({super.key, required this.label, required this.placeholder, required this.controller, this.keyboardType});

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

/// 发票信息页的下拉选择行（标签 + 点击选择）。
class MallConfirmOrderInvoiceSelectRow extends StatelessWidget {
  const MallConfirmOrderInvoiceSelectRow({super.key, required this.label, required this.value, required this.placeholder, required this.onTap});

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

/// 发票信息页的企业 / 个人单选项。
class MallConfirmOrderInvoiceTypeChoice extends StatelessWidget {
  const MallConfirmOrderInvoiceTypeChoice({super.key, required this.label, required this.selected, required this.onTap});

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
