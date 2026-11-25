import 'package:flutter/material.dart';

/// 积分商城兑换确认弹窗
///
/// 规格与订单页「取消订单」弹窗保持一致（紧凑样式，适配小屏设备）：
///   - 卡片高 160，圆角 14，白色背景，宽度随屏幕（水平边距 13）
///   - 标题 18px Medium，居中，距顶 32
///   - 底部按钮区高 60，取消(#8E8E97) / 确认(#213775) 两按钮均分宽度，按钮字号 22
///   - 遮罩 rgba(0,0,0,0.3)
class ExchangeConfirmDialog extends StatelessWidget {
  const ExchangeConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 13),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 414, minHeight: 140, maxHeight: 140),
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text(
                  '你确定要兑换该商品吗？',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF000000), height: 1.4),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE5E5EA))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF8E8E97), shape: const RoundedRectangleBorder()),
                          child: const Text('取消', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, height: 1.4)),
                        ),
                      ),
                      const SizedBox(
                        height: double.infinity,
                        child: VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE5E5EA)),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF213775), shape: const RoundedRectangleBorder()),
                          child: const Text('确认', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, height: 1.4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
