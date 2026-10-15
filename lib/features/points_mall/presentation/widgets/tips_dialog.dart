import 'package:flutter/material.dart';

/// 通用提示弹窗（单按钮 Alert 风格）
/// 用于无权限、提示信息等阻断场景
class TipsDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final VoidCallback? onConfirm;

  const TipsDialog({super.key, this.title = '提示', required this.content, this.confirmText = '确定', this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题 + 内容区域
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A), height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF666666), height: 1.5),
                  ),
                ],
              ),
            ),

            // 分割线
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA)),

            // 单按钮
            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  onConfirm?.call();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFF213775)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
