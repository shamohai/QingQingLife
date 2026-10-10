import 'package:flutter/material.dart';

/// 表单输入行组件 — 标签 + 灰色输入行
///
/// 适用于填写信息页的 6 个标准输入字段。
/// 两种模式：
/// - text 模式：左侧 icon/图片 + 右侧提示文字（或实际输入值），通过 valueWidget 传入 TextField
/// - picker 模式：左侧 icon/图片 + 显示文字 + 右侧 chevron，点击触发 onTap
class BookingFormField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? imageAsset;
  final Widget? valueWidget;
  final String? hint;
  final bool showChevron;
  final VoidCallback? onTap;

  const BookingFormField({
    super.key,
    required this.label,
    this.icon,
    this.imageAsset,
    this.valueWidget,
    this.hint,
    this.showChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF213775),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: showChevron ? onTap : null,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                if (imageAsset != null)
                  Image.asset(imageAsset!, width: 20, height: 20, color: const Color(0xFF213775))
                else if (icon != null)
                  Icon(icon, size: 20, color: const Color(0xFF213775)),
                const SizedBox(width: 12),
                if (valueWidget != null)
                  Expanded(child: valueWidget!),
                if (showChevron)
                  const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF8E8E93)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
