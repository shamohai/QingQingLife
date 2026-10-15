import 'package:flutter/material.dart';

/// 积分商城兑换确认弹窗
///
/// 设计稿规格：
///   - 卡片 414×207，圆角 14，白色背景
///   - 标题 20px Medium，居中
///   - 取消(#8E8E97) / 确认(#213775) 两按钮，均分宽度
///   - 遮罩 rgba(0,0,0,0.3)
class ExchangeConfirmDialog extends StatelessWidget {
  const ExchangeConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 13),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 207),
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '你确定要兑换该商品吗？',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text(
                      '取消',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Color(0xFF8E8E97)),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 0.5, color: Color(0xFFE5E5EA)),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text(
                      '确认',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Color(0xFF213775)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
